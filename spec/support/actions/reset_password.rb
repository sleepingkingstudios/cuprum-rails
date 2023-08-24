# frozen_string_literal: true

require 'cuprum/rails/action'
require 'cuprum/rails/actions/parameter_validation'

require 'support/actions'

module Spec::Support::Actions
  class ResetPassword < Cuprum::Rails::Action
    include Cuprum::Rails::Actions::ParameterValidation

    CONTRACT =
      Cuprum::Rails::Constraints::ParametersContract.new do
        key :password,     Stannum::Constraints::Presence.new
        key :confirmation, Stannum::Constraints::Presence.new
      end

    private

    def process(**)
      super

      step { require_authorization }

      step { validate_parameters(CONTRACT) }

      { 'ok' => true }
    end

    def require_authorization
      return if request.authorization

      error = Cuprum::Error.new(message: 'not authorized')
      failure(error)
    end
  end
end
