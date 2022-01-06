# frozen_string_literal: true

require 'cuprum/collections/errors/failed_validation'

require 'cuprum/rails/actions'
require 'cuprum/rails/actions/resource_action'

module Cuprum::Rails::Actions
  # Action to build and insert a resource instance.
  class Create < Cuprum::Rails::Actions::ResourceAction
    private

    attr_reader :entity

    def build_response
      { singular_resource_name => entity }
    end

    def create_entity(attributes:)
      steps do
        @entity = step { collection.build_one.call(attributes: attributes) }

        step { collection.validate_one.call(entity: entity) }

        step { collection.insert_one.call(entity: entity) }
      end
    end

    def failed_validation?(result)
      result.failure? &&
        result.error.is_a?(Cuprum::Collections::Errors::FailedValidation)
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
        create_entity(attributes: resource_params)
      end
    end

    def process(request:)
      @entity = nil

      super
    end

    def validate_parameters
      require_resource_params
    end
  end
end
