# frozen_string_literal: true

require 'stannum/constraints/presence'

require 'cuprum/rails/action'

require 'support/actions'

module Spec::Support::Actions
  class Login < Cuprum::Rails::Action
    validate_parameters do
      key :username, Stannum::Constraints::Presence.new
      key :password, Stannum::Constraints::Presence.new
    end

    private

    def process(**)
      super

      { 'ok' => true }
    end
  end
end
