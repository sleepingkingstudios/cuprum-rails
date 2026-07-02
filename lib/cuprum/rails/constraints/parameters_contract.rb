# frozen_string_literal: true

require 'stannum/contracts/indifferent_hash_contract'

require 'cuprum/rails/constraints'

module Cuprum::Rails::Constraints
  # Contract for validating request parameters.
  class ParametersContract < Stannum::Contracts::IndifferentHashContract
    def initialize(**)
      super(allow_extra_keys: true, **)
    end
  end
end
