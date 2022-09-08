# frozen_string_literal: true

require 'stannum/constraints/presence'

require 'cuprum/rails/action'
require 'cuprum/rails/actions/parameter_validation'

require 'support/actions'

module Spec::Support::Actions
  class Login < Cuprum::Rails::Action
    include Cuprum::Rails::Actions::ParameterValidation

    validate_parameters do
      key :username, Stannum::Constraints::Presence.new
      key :password, Stannum::Constraints::Presence.new
    end

    private

    def process(request:)
      super

      { 'ok' => true }
    end
  end
end
