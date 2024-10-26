# frozen_string_literal: true

require 'cuprum/collections/errors/failed_validation'
require 'stannum/errors'

require 'cuprum/rails/actions/resources/concerns'

module Cuprum::Rails::Actions::Resources::Concerns
  # Shared methods for handling commands that validate entities.
  module EntityValidation
    private

    def call_command(command, **)
      handle_validation_error { super }
    end

    def handle_validation_error
      result = yield

      return result unless result.value && validation_error?(result)

      build_result(
        **result.properties,
        value: build_response(result.value),
        error: map_validation_error(result.error)
      )
    end

    def map_validation_error(error)
      errors = Stannum::Errors.new

      error.errors.each do |err|
        errors
          .dig(resource.singular_name, *err[:path].map(&:to_s))
          .add(err[:type], message: err[:message], **err[:data])
      end

      Cuprum::Collections::Errors::FailedValidation.new(
        entity_class: error.entity_class,
        errors:
      )
    end

    def validation_error?(result)
      return false if result.success?

      result.error&.type == Cuprum::Collections::Errors::FailedValidation::TYPE
    end
  end
end
