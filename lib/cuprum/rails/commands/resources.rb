# frozen_string_literal: true

require 'cuprum/rails/commands'

module Cuprum::Rails::Commands
  # Namespace for commands that implement resourceful controller actions.
  module Resources
    autoload :Concerns, 'cuprum/rails/commands/resources/concerns'
    autoload :Index,    'cuprum/rails/commands/resources/index'
    autoload :New,      'cuprum/rails/commands/resources/new'
  end
end
