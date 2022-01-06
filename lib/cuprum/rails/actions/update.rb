# frozen_string_literal: true

require 'cuprum/collections/errors/failed_validation'

require 'cuprum/rails/actions'
require 'cuprum/rails/actions/resource_action'

module Cuprum::Rails::Actions
  # Action to assign and update a resource instance by primary key.
  class Update < Cuprum::Rails::Actions::ResourceAction
    private

    attr_reader :entity

    def build_response
      { singular_resource_name => entity }
    end

    def failed_validation?(result)
      result.failure? &&
        result.error.is_a?(Cuprum::Collections::Errors::FailedValidation)
    end

    def find_entity(primary_key:)
      collection.find_one.call(primary_key: primary_key)
    end

    def find_required_entities
      @entity = step { find_entity(primary_key: resource_id) }
    end

    def handle_failed_validation
      result = yield

      return result unless failed_validation?(result)

      Cuprum::Result.new(
        error:  result.error,
        status: :failure,
        value:  { singular_resource_name => entity }
      )
    end

    def perform_action
      handle_failed_validation do
        update_entity(attributes: resource_params)
      end
    end

    def process(request:)
      @entity = nil

      super
    end

    def update_entity(attributes:)
      steps do
        step do
          collection.assign_one.call(attributes: attributes, entity: entity)
        end

        step { collection.validate_one.call(entity: entity) }

        step { collection.update_one.call(entity: entity) }
      end
    end

    def validate_parameters
      step { require_resource_id }
      step { require_resource_params }
    end
  end
end
