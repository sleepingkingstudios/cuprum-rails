# frozen_string_literal: true

require 'cuprum/collections/errors/failed_validation'

require 'cuprum/rails/actions'
require 'cuprum/rails/actions/resource_action'

module Cuprum::Rails::Actions
  # Action to assign and update a resource instance by primary key.
  class Update < Cuprum::Rails::Actions::ResourceAction
    private

    def assign_resource
      entity = step do
        collection.find_one.call(primary_key: resource_id)
      end

      step do
        collection.assign_one.call(attributes: resource_params, entity: entity)
      end
    end

    def failed_validation?(result)
      result.failure? &&
        result.error.is_a?(Cuprum::Collections::Errors::FailedValidation)
    end

    def process(request:)
      super

      step { require_resource_id }
      step { require_resource_params }

      entity, result = update_resource

      return result unless failed_validation?(result)

      Cuprum::Result.new(
        error:  result.error,
        status: :failure,
        value:  { singular_resource_name => entity }
      )
    end

    def update_resource
      entity = nil

      result = steps do
        entity = assign_resource

        step { collection.validate_one.call(entity: entity) }

        step { collection.update_one.call(entity: entity) }

        { singular_resource_name => entity }
      end

      [entity, result]
    end
  end
end
