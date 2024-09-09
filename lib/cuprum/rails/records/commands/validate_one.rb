# frozen_string_literal: true

require 'cuprum/collections/errors/failed_validation'

require 'cuprum/rails/map_errors'
require 'cuprum/rails/records/command'
require 'cuprum/rails/records/commands'

module Cuprum::Rails::Records::Commands
  # Command for validating an ActiveRecord record.
  class ValidateOne < Cuprum::Rails::Records::Command
    # @!method call(entity:, contract: nil)
    #   Validates the record against the given or default contract.
    #
    #   If the record matches the contract, #call will return a passing result
    #   with the record as the result value. If the record does not match the
    #   contract, #call will return a failing result with a FailedValidation
    #   error and the validation errors.
    #
    #   @param contract [Stannum::Constraints:Base] The contract with which to
    #     validate the record. If not given, the record will be validated using
    #     the collection's default contract.
    #   @param entity [ActiveRecord::Base] The collection record to validate.
    #
    #   @return [Cuprum::Result<ActiveRecord::Base>] the validated record.
    validate :contract, Stannum::Constraints::Base, optional: true
    validate :entity

    private

    def map_errors(native_errors:)
      Cuprum::Rails::MapErrors.instance.call(native_errors:)
    end

    def match_default(entity:)
      return true if entity.valid?

      errors = map_errors(native_errors: entity.errors)

      [false, errors]
    end

    def process(entity:, contract: nil)
      step { validate_entity(entity) }

      step { validate_record(contract:, entity:) }

      entity
    end

    def validate_record(contract:, entity:)
      valid, errors =
        contract ? contract.match(entity) : match_default(entity:)

      return if valid

      error = Cuprum::Collections::Errors::FailedValidation.new(
        entity_class: entity.class,
        errors:
      )
      failure(error)
    end
  end
end
