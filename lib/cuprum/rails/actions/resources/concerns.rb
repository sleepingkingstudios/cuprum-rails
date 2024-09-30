# frozen_string_literal: true

require 'cuprum/rails/actions/resources'

module Cuprum::Rails::Actions::Resources
  # Namespace for shared functionality for resourceful actions.
  module Concerns
    autoload :ResourceParameters,
      'cuprum/rails/actions/resources/concerns/resource_parameters'
  end
end
