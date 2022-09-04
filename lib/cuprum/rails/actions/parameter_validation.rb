# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox/mixin'
require 'stannum/contracts/indifferent_hash_contract'

require 'cuprum/rails/actions'

module Cuprum::Rails::Actions
  # Mixin for adding parameter validation to an Action.
  module ParameterValidation
    extend SleepingKingStudios::Tools::Toolbox::Mixin

    # Class methods to extend when including the mixin.
    module ClassMethods
      # @overload validate_parameters(contract)
      #   Sets the contract to automatically validate the request parameters.
      #
      #   @param contract [Stannum::Contract] the contract used to validate the
      #     request parameters.
      #
      # @overload validate_parameters(&block)
      #   Defines a contract to automatically validate the request parameters.
      #
      #   @yield Used to create an indifferent hash contract to validate the
      #     request parameters.
      def validate_parameters(contract = nil, &block)
        contract ||=
          Stannum::Contracts::IndifferentHashContract.new(
            allow_extra_keys: true,
            &block
          )

        define_method(:parameters_contract) { contract }
      end
    end

    private

    def parameters_contract
      nil
    end

    def process(request:)
      super

      return unless validate_parameters?

      step { validate_parameters(parameters_contract) }
    end

    def validate_parameters(contract)
      match, errors = contract.match(params)

      return success(nil) if match

      error = Cuprum::Rails::Errors::InvalidParameters.new(errors: errors)
      failure(error)
    end

    def validate_parameters?
      !parameters_contract.nil?
    end
  end
end
