# frozen_string_literal: true

require 'cuprum/rails'

module Cuprum::Rails
  # Namespace for Stannum constraints and contracts, which validate objects.
  module Constraints
    autoload :ParametersContract, 'cuprum/rails/constraints/parameters_contract'
  end
end
