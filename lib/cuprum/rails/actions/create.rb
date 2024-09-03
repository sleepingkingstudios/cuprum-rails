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
      { resource.singular_name => entity }
    end

    def create_entity(attributes:)
      steps do
        @entity = step { collection.build_one.call(attributes:) }

        step { collection.validate_one.call(entity:) }

        step { collection.insert_one.call(entity:) }
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
        error:  scope_validation_errors(result.error),
        status: :failure,
        value:  { resource.singular_name => entity }
      )
    end

    def parameters_contract
      return @parameters_contract if @parameters_contract

      resource_name         = resource.singular_name
      parameters_constraint = require_parameters_constraint

      @parameters_contract =
        Cuprum::Rails::Constraints::ParametersContract.new do
          key resource_name, parameters_constraint
        end
    end

    def perform_action
      handle_failed_validation do
        create_entity(attributes: resource_params)
      end
    end

    def process(**)
      @entity = nil

      super
    end

    def require_parameters_constraint
      Stannum::Contract.new do
        constraint Stannum::Constraints::Presence.new, sanity: true
        constraint Stannum::Constraints::Types::HashType.new
      end
    end

    def require_permitted_attributes?
      true
    end

    def scope_validation_errors(error)
      mapped_errors = Stannum::Errors.new

      error.errors.each do |err|
        mapped_errors
          .dig(resource.singular_name, *err[:path].map(&:to_s))
          .add(err[:type], message: err[:message], **err[:data])
      end

      Cuprum::Collections::Errors::FailedValidation.new(
        entity_class: error.entity_class,
        errors:       mapped_errors
      )
    end
  end
end
