# frozen_string_literal: true

require 'cuprum/collections/errors/failed_validation'

require 'cuprum/rails/commands'

module Cuprum::Rails::Commands
  # Utility command for validating an entity for a collection.
  class ValidateEntity < Cuprum::Command
    # @param collection [Cuprum::Collection] the collection used to validate the
    #   entity.
    def initialize(collection:)
      super()

      @collection = collection
    end

    # @return [Cuprum::Collection] the collection used to validate the entity.
    attr_reader :collection

    private

    def process(entity:)
      result = collection.validate_one.call(entity:)

      return result if result.success?

      unless result.error.is_a?(Cuprum::Collections::Errors::FailedValidation)
        return result
      end

      build_result(
        **result.properties,
        value: entity
      )
    end
  end
end
