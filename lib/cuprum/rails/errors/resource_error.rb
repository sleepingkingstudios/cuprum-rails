# frozen_string_literal: true

require 'cuprum/error'

require 'cuprum/rails/errors'

module Cuprum::Rails::Errors
  # Error class when a resource is not correctly configured for an action.
  class ResourceError < Cuprum::Error
    # Short string used to identify the type of error.
    TYPE = 'cuprum.rails.errors.resource_error'

    # @param resource [Cuprum::Rails::Resource] the errored resource.
    # @param message [String] the message to display, if any.
    def initialize(resource:, message: nil)
      @resource = resource

      super(message: generate_message(message), resource: resource)
    end

    # @return [Cuprum::Rails::Resource] the errored resource.
    attr_reader :resource

    private

    def as_json_data
      {
        'resource' => {
          'resource_class' => resource.resource_class.to_s,
          'resource_name'  => resource.resource_name.to_s,
          'singular'       => resource.singular?
        }
      }
    end

    def generate_message(message = nil)
      prefix = "invalid resource #{resource.resource_name}"

      return prefix if message.blank?

      "#{prefix} - #{message}"
    end
  end
end
