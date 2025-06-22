# frozen_string_literal: true

require 'cuprum/rails/rspec'

module Cuprum::Rails::RSpec
  # Namespace for custom RSpec matchers.
  module Matchers
    autoload :BeAResultMatcher,
      'cuprum/rails/rspec/matchers/be_a_result_matcher'

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

    # Asserts that the object is a Cuprum::Result.
    #
    # @return [Cuprum::Rails::RSpec::Matchers::BeAResultMatcher] the generated
    #   matcher.
    def be_a_result(expected_class = nil)
      Cuprum::Rails::RSpec::Matchers::BeAResultMatcher.new(expected_class)
    end

    # Asserts that the value is an ActiveRecord timestamp.
    #
    # @param optional [true, false] if true, allows nil values. Defaults to
    #   false.
    #
    # @return [RSpec::Matchers::BuiltIn::BaseMatcher] the generated matcher.
    def be_a_timestamp(optional: false)
      matcher = be_a(ActiveSupport::TimeWithZone)

      return matcher unless optional

      matcher.or(be(nil))
    end
    alias a_timestamp be_a_timestamp

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
  end
end
