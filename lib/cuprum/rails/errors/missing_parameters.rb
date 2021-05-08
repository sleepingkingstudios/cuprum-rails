# frozen_string_literal: true

require 'cuprum/error'

require 'cuprum/rails/errors'

module Cuprum::Rails::Errors
  # Error class when a parameters hash does not include a resource.
  class MissingParameters < Cuprum::Error
    # Short string used to identify the type of error.
    TYPE = 'cuprum.rails.errors.missing_parameters'

    # @param resource_name [Cuprum::Rails::Resource] The name of the resource.
    def initialize(resource_name:)
      @resource_name = resource_name

      super(message: default_message, resource_name: resource_name)
    end

    # @return [Cuprum::Rails::Resource] the name of the resource.
    attr_reader :resource_name

    private

    def as_json_data
      { 'resource_name' => resource_name }
    end

    def default_message
      "The #{resource_name.inspect} parameter is missing or empty"
    end
  end
end
