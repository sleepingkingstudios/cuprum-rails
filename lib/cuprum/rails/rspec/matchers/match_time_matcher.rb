# frozen_string_literal: true

require 'cuprum/rails/rspec/matchers'

module Cuprum::Rails::RSpec::Matchers
  # Matcher for comparing two time-like values.
  class MatchTimeMatcher
    # @param expected [ActiveSupport::TimeWithZone, Date, DateTime, Time,
    #   Integer, String] the expected time-like object.
    def initialize(expected)
      @expected = expected
    end

    # @return [Object] the object being matched.
    attr_reader :actual

    # @return [ActiveSupport::TimeWithZone, Date, DateTime, Time, Integer,
    #   String] the expected time-like object.
    attr_reader :expected

    # @return [String] a human-readable description of the matcher.
    def description
      "match time #{expected.inspect}"
    end

    # @return [String] a message explaining the reason for the failed match.
    def failure_message # rubocop:disable Metrics/MethodLength
      message = "expected #{actual.inspect} to #{description}"

      case failure_reason
      when :actual_time_invalid
        "#{message}, but the actual value is not a valid time"
      when :expected_time_invalid
        "#{message}, but the expected value is not a valid time"
      when :time_mismatch
        "#{message}, but the times do not match"
      else
        # :nocov:
        message
        # :nocov:
      end
    end

    # @return [String] a message explaining the reason for the failed match.
    def failure_message_when_negated
      message = "expected #{actual.inspect} not to #{description}"

      case failure_reason
      when :actual_time_invalid
        "#{message}, but the actual value is not a valid time"
      when :expected_time_invalid
        "#{message}, but the expected value is not a valid time"
      else
        message
      end
    end

    # Checks if the actual and expected values are non-matching times.
    #
    # @param actual [Object] the object to match.
    #
    # @return [true, false] true if the actual and expected values are both
    #   valid times and are not equivalent; otherwise false.
    def does_not_match?(actual) # rubocop:disable Naming/PredicatePrefix
      @actual        = actual
      @actual_time   = normalize_value(actual)
      @expected_time = normalize_value(expected)

      valid_times? && !time_matches?
    end

    # Checks if the actual and expected values are matching times.
    #
    # @param actual [Object] the object to match.
    #
    # @return [true, false] true if the actual and expected values are both
    #   valid times and are equivalent; otherwise false.
    def matches?(actual)
      @actual        = actual
      @actual_time   = normalize_value(actual)
      @expected_time = normalize_value(expected)

      valid_times? && time_matches?
    end

    private

    attr_reader :actual_time

    attr_reader :expected_time

    attr_reader :failure_reason

    def normalize_value(value)
      value = Time.at(value, in: 'Z') if value.is_a?(Integer)
      value = DateTime.parse(value)   if value.is_a?(String)
      value = value.to_datetime       if value.is_a?(Date)

      return nil unless value.respond_to?(:utc)

      truncate(value.utc)
    rescue Date::Error
      nil
    end

    def time_matches?
      return true if actual_time == expected_time

      @failure_reason = :time_mismatch

      false
    end

    def truncate(time)
      Time.at(time.to_i, in: 'Z')
    end

    def valid_times?
      return true if expected_time && actual_time

      @failure_reason =
        if expected_time
          :actual_time_invalid
        else
          :expected_time_invalid
        end

      false
    end
  end
end
