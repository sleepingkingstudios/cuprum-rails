# frozen_string_literal: true

require 'cuprum/collections/errors/failed_validation'

require 'cuprum/rails/actions'
require 'cuprum/rails/actions/resource_action'

module Cuprum::Rails::Actions
  # Action to build and insert a resource instance.
  class Create < Cuprum::Rails::Actions::ResourceAction
    private

    def create_resource
      entity = nil

      result = steps do
        entity = step { collection.build_one.call(attributes: resource_params) }

        step { collection.validate_one.call(entity: entity) }

        step { collection.insert_one.call(entity: entity) }

        { singular_resource_name => entity }
      end

      [entity, result]
    end

    def failed_validation?(result)
      result.failure? &&
        result.error.is_a?(Cuprum::Collections::Errors::FailedValidation)
    end

    def process(request:)
      super

      step { require_resource_params }

      entity, result = create_resource

      return result unless failed_validation?(result)

      Cuprum::Result.new(
        error:  result.error,
        status: :failure,
        value:  { singular_resource_name => entity }
      )
    end
  end
end
