# frozen_string_literal: true

require 'cuprum/rails/commands'

module Cuprum::Rails::Commands
  # Namespace for commands that implement resourceful controller actions.
  module Resources
    autoload :Index, 'cuprum/rails/commands/resources/index'
  end
end
