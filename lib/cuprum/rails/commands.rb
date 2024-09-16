# frozen_string_literal: true

require 'cuprum/rails'

module Cuprum::Rails
  # Namespace for custom command objects.
  module Commands
    autoload :ResourceCommand, 'cuprum/rails/commands/resource_command'
    autoload :Resources,       'cuprum/rails/commands/resources'
  end
end
