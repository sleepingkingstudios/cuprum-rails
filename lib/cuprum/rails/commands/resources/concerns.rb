# frozen_string_literal: true

require 'cuprum/rails/commands/resources'

module Cuprum::Rails::Commands::Resources
  # Namespace for shared functionality for resourceful commands.
  module Concerns
    autoload :PermittedAttributes,
      'cuprum/rails/commands/resources/concerns/permitted_attributes'
  end
end
