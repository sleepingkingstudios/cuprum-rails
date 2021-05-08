# frozen_string_literal: true

require 'cuprum/error'

require 'cuprum/rails/errors'

module Cuprum::Rails::Errors
  # Error class when a parameters hash does not include a primary key.
  class MissingPrimaryKey < Cuprum::Error
    # Short string used to identify the type of error.
    TYPE = 'cuprum.rails.errors.missing_primary_key'

    # @param primary_key [String, Symbol] The name of the resource primary key.
    # @param resource_name [Cuprum::Rails::Resource] The name of the resource.
    def initialize(primary_key:, resource_name:)
      @primary_key   = primary_key
      @resource_name = resource_name

      super(
        message:       default_message,
        primary_key:   primary_key,
        resource_name: resource_name
      )
    end

    # @return [String] the name of the resource primary key.
    attr_reader :primary_key

    # @return [Cuprum::Rails::Resource] the name of the resource.
    attr_reader :resource_name

    private

    def as_json_data
      {
        'primary_key'   => primary_key,
        'resource_name' => resource_name
      }
    end

    def default_message
      "Unable to find #{resource_name} because the #{primary_key.inspect}" \
      ' parameter is missing or empty'
    end
  end
end
