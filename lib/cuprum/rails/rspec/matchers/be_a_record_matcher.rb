# frozen_string_literal: true

require 'set'

require 'rspec/matchers/composable'

require 'cuprum/rails/rspec/matchers'
require 'cuprum/rails/rspec/matchers/match_time_matcher'

module Cuprum::Rails::RSpec::Matchers
  # Matcher asserting the object is a record with the expected attributes.
  class BeARecordMatcher # rubocop:disable Metrics/ClassLength
    include RSpec::Matchers::Composable

    TIME_CLASSES = [ActiveSupport::TimeWithZone, Date, DateTime, Time].freeze
    private_constant :TIME_CLASSES

    # @param expected [Class] the expected record class.
    def initialize(expected)
      @expected               = expected
      @allow_extra_attributes = true
      @ignore_timestamps      = true
    end

    # @return [Object] the object being matched.
    attr_reader :actual

    # @return [Class] the expected record class.
    attr_reader :expected
    alias record_class expected

    # @return [Hash, #matches?, nil] the expected attributes for the record.
    attr_reader :expected_attributes

    # @return [true, false] if true, ignores attributes not listed in expected
    #   attributes.
    def allow_extra_attributes?
      @allow_extra_attributes
    end

    # @return [String] a human-readable description of the matcher.
    def description
      return expected_description unless expected_attributes

      "#{expected_description} with expected attributes"
    end

    # Checks if the value is the expected class and has the expected attributes.
    #
    # @param actual [Object] the object to match.
    #
    # @return [true, false] true if the object does not the expected class and
    #   attributes; otherwise false.
    def does_not_match?(actual) # rubocop:disable Naming/PredicatePrefix
      !matches?(actual)
    end

    # @return [String] a message explaining the reason for the failed match.
    def failure_message # rubocop:disable Metrics/MethodLength
      message = "expected #{actual.inspect} to #{description}"

      case failure_reason
      when :attributes_mismatch
        message = "#{message}, but the attributes do not match:"
        "#{message}#{diff_attributes}"
      when :record_class_mismatch
        failure =
          actual.nil? ? 'is nil' : "is an instance of #{actual.class.name}"

        "#{message}, but #{failure}"
      else
        # :nocov:
        message
        # :nocov:
      end
    end

    # @return [String] a message explaining the reason for the failed match.
    def failure_message_when_negated
      "expected #{actual.inspect} not to #{description}"
    end

    # @return [true, false] if true, ignores created_at and updated_at
    #   attributes.
    def ignore_timestamps?
      @ignore_timestamps
    end

    # Checks if the value is the expected class and has the expected attributes.
    #
    # @param actual [Object] the object to match.
    #
    # @return [true, false] true if the object matches the expected class and
    #   attributes; otherwise false.
    def matches?(actual)
      @actual = actual

      matches_record_class? && matches_attributes?
    end

    # Adds an attributes expectation to the matcher.
    def with_attributes(
      expected_attributes,
      allow_extra_attributes: nil,
      ignore_timestamps:      nil
    )
      apply_options({ allow_extra_attributes:, ignore_timestamps: }.compact)

      @expected_attributes = normalize_expected_attributes(expected_attributes)

      self
    end

    private

    attr_reader :extra_attributes

    attr_reader :failure_reason

    attr_reader :missing_attributes

    attr_reader :non_matching_attributes

    def actual_attributes(filter_attributes: true)
      hsh = actual.respond_to?(:attributes) ? actual.attributes : actual
      hsh = tools.hash_tools.convert_keys_to_strings(hsh)

      return hsh unless filter_attributes

      hsh = remove_timestamps(hsh) if ignore_timestamps?

      hsh
    end

    def all_attribute_keys
      [
        *actual_attributes(filter_attributes: false).keys,
        *expected_attributes.keys
      ].uniq
    end

    def apply_options(options)
      if options.key?(:allow_extra_attributes)
        @allow_extra_attributes = options[:allow_extra_attributes]
      end

      if options.key?(:ignore_timestamps) # rubocop:disable Style/GuardClause
        @ignore_timestamps = options[:ignore_timestamps]
      end
    end

    def attribute_matches?(expected_attribute, value)
      return expected_attribute.matches?(value) if matcher?(expected_attribute)

      if timestamp?(expected_attribute) || timestamp?(value)
        return MatchTimeMatcher.new(expected_attribute).matches?(value)
      end

      expected_attribute == value
    end

    def attributes_match?
      if matcher?(expected_attributes)
        return expected_attributes.matches?(actual_attributes)
      end

      @extra_attributes        = find_extra_attributes
      @non_matching_attributes = find_non_matching_attributes

      extra_attributes.empty? && non_matching_attributes.empty?
    end

    def diff_attributes # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      if matcher?(expected_attributes)
        return " expected attributes to #{expected_attributes.description}"
      end

      diff       = +"\n\n"
      attributes = actual_attributes(filter_attributes: false)

      all_attribute_keys.each do |key|
        if !attributes.key?(key)
          diff << "- #{key}: #{format_expected_attribute(key)}\n"
        elsif non_matching_attributes.include?(key)
          diff << "- #{key}: #{format_expected_attribute(key)}\n"
          diff << "+ #{key}: #{attributes[key].inspect}\n"
        elsif extra_attributes.include?(key)
          diff << "+ #{key}: #{attributes[key].inspect}\n"
        else
          diff << "  #{key}: #{attributes[key].inspect}\n"
        end
      end

      diff
    end

    def expected_description
      return expected.description if matcher?(expected)

      "be a #{expected.name}"
    end

    def find_extra_attributes
      extra_attributes = Set.new

      return extra_attributes if allow_extra_attributes?

      actual_attributes.each_key do |key|
        next if expected_attributes.key?(key)

        extra_attributes << key
      end

      extra_attributes
    end

    def find_non_matching_attributes
      non_matching_attributes = Set.new
      unfiltered_attributes   = actual_attributes(filter_attributes: false)

      expected_attributes.each do |key, expected_attribute|
        if attribute_matches?(expected_attribute, unfiltered_attributes[key])
          next
        end

        non_matching_attributes << key
      end

      non_matching_attributes
    end

    def format_expected_attribute(key)
      expected_attribute = expected_attributes[key]

      return expected_attribute.description if matcher?(expected_attribute)

      expected_attribute.inspect
    end

    def matcher?(maybe_matcher)
      maybe_matcher.respond_to?(:failure_message, :matches?)
    end

    def matches_attributes?
      return true unless expected_attributes

      return true if attributes_match?

      @failure_reason = :attributes_mismatch

      false
    end

    def matches_record_class?
      return true if record_class_matches?

      @failure_reason = :record_class_mismatch

      false
    end

    def normalize_expected_attributes(expected_attributes)
      return expected_attributes unless expected_attributes.is_a?(Hash)

      if ignore_timestamps?
        expected_attributes = remove_timestamps(expected_attributes)
      end

      tools.hash_tools.convert_keys_to_strings(expected_attributes)
    end

    def record_class_matches?
      return true if matcher?(expected) && expected.matches?(actual)

      return true if expected.is_a?(Module) && actual.is_a?(expected)

      false
    end

    def remove_timestamps(hsh)
      hsh.except('created_at', 'updated_at', :created_at, :updated_at)
    end

    def timestamp?(value)
      TIME_CLASSES.any? { |klass| value.is_a?(klass) }
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
