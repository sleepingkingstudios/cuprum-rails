# frozen_string_literal: true

require 'cuprum/rails'

module Cuprum::Rails
  # Namespace for custom command objects.
  module Commands
    autoload :PermitAttributes, 'cuprum/rails/commands/permit_attributes'
    autoload :ResourceCommand,  'cuprum/rails/commands/resource_command'
    autoload :Resources,        'cuprum/rails/commands/resources'
    autoload :ValidateEntity,   'cuprum/rails/commands/validate_entity'
  end
end
