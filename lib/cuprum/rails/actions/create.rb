# frozen_string_literal: true

require 'cuprum/collections/errors/failed_validation'

require 'cuprum/rails/actions'
require 'cuprum/rails/actions/resource_action'

module Cuprum::Rails::Actions
  # Action to build and insert a resource instance.
  class Create < Cuprum::Rails::Actions::ResourceAction
    private

    def create_resource
      resource = nil

      result = steps do
        attributes = step { resource_params }
        resource   = step { collection.build_one.call(attributes: attributes) }

        step { collection.validate_one.call(entity: resource) }

        step { collection.insert_one.call(entity: resource) }

        { singular_resource_name => resource }
      end

      [resource, result]
    end

    def failed_validation?(result)
      result.failure? &&
        result.error.is_a?(Cuprum::Collections::Errors::FailedValidation)
    end

    def process(request:)
      super

      resource, result = create_resource

      return result unless failed_validation?(result)

      Cuprum::Result.new(
        error:  result.error,
        status: :failure,
        value:  { singular_resource_name => resource }
      )
    end
  end
end
