# frozen_string_literal: true

require 'cuprum/rails/rspec/matchers'

module Cuprum::Rails::RSpec::Matchers
  # Asserts the actual object is a result object with the specified properties.
  #
  # @see Cuprum::RSpec::BeAResultMatcher.
  class BeAResultMatcher < Cuprum::RSpec::BeAResultMatcher
    # @param expected_class [Class] the expected class of result. Defaults to
    #   Cuprum::Result.
    def initialize(expected_class = nil)
      super

      @expected_metadata = DEFAULT_VALUE
    end

    # Sets a metadata expectation on the matcher.
    #
    # Calls to #matches? will fail unless the result responds to #metadata? and
    # has the specified metadata.
    def with_metadata(metadata)
      @expected_metadata = metadata

      self
    end
    alias and_metadata with_metadata

    private

    attr_reader :expected_metadata

    def expected_metadata?
      expected_metadata != DEFAULT_VALUE
    end

    def expected_properties
      return super unless expected_metadata?

      super.merge('metadata' => expected_metadata)
    end

    def metadata_failure_message
      return '' if metadata_matches?

      unless actual.respond_to?(:metadata)
        return "\n  actual does not respond to #metadata"
      end

      "#{pad_key('expected metadata')}#{inspect_expected(expected_metadata)}" \
        "#{pad_key('actual metadata')}#{result.metadata.inspect}"
    end

    def metadata_matches?
      return @metadata_matches unless @metadata_matches.nil?

      return @metadata_matches unless expected_metadata?

      return @metadata_matches = false unless actual.respond_to?(:metadata)

      @metadata_matches = compare_items(expected_metadata, result.metadata)
    end
  end
end
