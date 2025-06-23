# frozen_string_literal: true

require 'cuprum/rails/rspec'

module Cuprum::Rails::RSpec
  # Namespace for custom RSpec matchers.
  module Matchers
    autoload :BeARecordMatcher,
      'cuprum/rails/rspec/matchers/be_a_record_matcher'
    autoload :BeAResultMatcher,
      'cuprum/rails/rspec/matchers/be_a_result_matcher'
    autoload :MatchTimeMatcher,
      'cuprum/rails/rspec/matchers/match_time_matcher'

    # Asserts that the object is a result with status: :failure.
    #
    # @param expected_class [Class] the expected class of result. Defaults to
    #   Cuprum::Result.
    #
    # @return [Cuprum::Rails::RSpec::Matchers::BeAResultMatcher] the generated
    #   matcher.
    def be_a_failing_result(expected_class = nil)
      be_a_result(expected_class).with_status(:failure)
    end

    # Asserts that the object is a Cuprum::Result with status: :success.
    #
    # @param expected_class [Class] the expected class of result. Defaults to
    #   Cuprum::Result.
    #
    # @return [Cuprum::Rails::RSpec::Matchers::BeAResultMatcher] the generated
    #   matcher.
    def be_a_passing_result(expected_class = nil)
      be_a_result(expected_class).with_status(:success).and_error(nil)
    end

    # Asserts that the object is a record, with chainable attributes.
    #
    # @param expected_class [Class] the expected record class.
    #
    # @return [Cuprum::Rails::RSpec::Matchers::BeARecordMatcher] the generated
    #   matcher.
    def be_a_record(expected_class)
      Cuprum::Rails::RSpec::Matchers::BeARecordMatcher.new(expected_class)
    end
    alias a_record be_a_record

    # Asserts that the object is a Cuprum::Result.
    #
    # @return [Cuprum::Rails::RSpec::Matchers::BeAResultMatcher] the generated
    #   matcher.
    def be_a_result(expected_class = nil)
      Cuprum::Rails::RSpec::Matchers::BeAResultMatcher.new(expected_class)
    end

    # Asserts the object is an instance of the class with expected attributes.
    #
    # If the attributes are nil, instead asserts that the value is nil.
    # Otherwise, the expected attributes will be coerced to match the record
    # class's columns.
    #
    # @param attributes [Hash, nil] the attributes expected for the value.
    # @param record_class [Class] the expected class for the value.
    #
    # @return [RSpec::Matchers::BuiltIn::BaseMatcher] the generated matcher.
    def match_record(attributes:, record_class:)
      return be(nil) if attributes.nil?

      matcher = be_a(record_class)

      return matcher if attributes.empty?

      record     = record_class.new(attributes)
      attributes = attributes.except('created_at', 'updated_at')
      attributes = attributes.each.to_h do |key, value|
        next [key, value] if value.respond_to?(:matches?)

        [key, record.send(key)]
      end

      matcher.and have_attributes(attributes)
    end

    # Asserts the object is a time representation matching the expected time.
    #
    # @param expected [ActiveSupport::TimeWithZone, Date, DateTime, Time,
    #   Integer, String] the expected time-like object.
    #
    # @return [Cuprum::Rails::RSpec::Matchers::MatchTimeMatcher]
    def match_time(expected)
      Cuprum::Rails::RSpec::Matchers::MatchTimeMatcher.new(expected)
    end
  end
end
