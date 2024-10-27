# frozen_string_literal: true

require 'stannum/contracts/hash_contract'

require 'cuprum/rails/actions/resources/concerns'
require 'cuprum/rails/errors/invalid_parameters'

module Cuprum::Rails::Actions::Resources::Concerns
  # Shared methods for mapping resource parameters.
  module ResourceParameters
    RESOURCE_PARAMETERS_CONTRACT = Stannum::Contract
      .new do
        constraint Stannum::Constraints::Presence.new, sanity: true
        constraint Stannum::Constraints::Types::HashType.new
      end
      .freeze
    private_constant :RESOURCE_PARAMETERS_CONTRACT

    private

    def require_resource_params
      match, errors = resource_parameters_contract.match(params)

      return resource_params if match

      error = Cuprum::Rails::Errors::InvalidParameters.new(errors:)
      failure(error)
    end

    def resource_parameters_contract
      resource_key = resource.singular_name.to_s

      Stannum::Contracts::HashContract.new(allow_extra_keys: true) do
        key(resource_key, RESOURCE_PARAMETERS_CONTRACT)
      end
    end

    def resource_params
      params[resource.singular_name] || {}
    end
  end
end
