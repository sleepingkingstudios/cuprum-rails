# frozen_string_literal: true

require 'cuprum/error'

require 'cuprum/rails/errors'

module Cuprum::Rails::Errors
  # Error class when a resource does not define permitted attributes.
  class UndefinedPermittedAttributes < Cuprum::Error
    # Short string used to identify the type of error.
    TYPE = 'cuprum.rails.errors.undefined_permitted_attributes'

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
      "Resource #{resource_name.inspect} does not define " \
        'permitted attributes'
    end
  end
end
