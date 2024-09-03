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

      super(message: generate_message(message), resource:)
    end

    # @return [Cuprum::Rails::Resource] the errored resource.
    attr_reader :resource

    private

    def as_json_data
      {
        'resource' => {
          'entity_class'   => resource.entity_class.to_s,
          'name'           => resource.name.to_s,
          'qualified_name' => resource.qualified_name.to_s,
          'singular'       => resource.singular?,
          'singular_name'  => resource.singular_name.to_s
        }
      }
    end

    def generate_message(message = nil)
      prefix = "invalid resource #{resource.name}"

      return prefix if message.blank?

      "#{prefix} - #{message}"
    end
  end
end
