# frozen_string_literal: true

require 'cuprum/rails/commands/resources/concerns'

module Cuprum::Rails::Commands::Resources::Concerns
  # Helper methods for validating command entities.
  module EntityValidation
    private

    def validate_entity(entity:)
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
