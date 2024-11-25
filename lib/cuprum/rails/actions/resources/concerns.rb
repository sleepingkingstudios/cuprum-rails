# frozen_string_literal: true

require 'cuprum/rails/actions/resources'

module Cuprum::Rails::Actions::Resources
  # Namespace for shared functionality for resourceful actions.
  module Concerns
    autoload :EntityValidation,
      'cuprum/rails/actions/resources/concerns/entity_validation'
    autoload :PrimaryKey,
      'cuprum/rails/actions/resources/concerns/primary_key'
    autoload :ResourceParameters,
      'cuprum/rails/actions/resources/concerns/resource_parameters'
  end
end
