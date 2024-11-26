# frozen_string_literal: true

require 'stannum/constraints/presence'
require 'stannum/errors'

require 'cuprum/rails/actions/resources/concerns'
require 'cuprum/rails/errors/invalid_parameters'

module Cuprum::Rails::Actions::Resources::Concerns
  # Shared methods for accessing a primary key parameter.
  module PrimaryKey
    private

    def primary_key_value
      params.fetch('id', params["#{resource.singular_name}_id"])
    end

    def require_primary_key_value
      value = primary_key_value

      return value if value

      errors = Stannum::Errors.new
      errors['id'].add(Stannum::Constraints::Presence::TYPE)

      error = Cuprum::Rails::Errors::InvalidParameters.new(errors:)
      failure(error)
    end
  end
end
