# frozen_string_literal: true

require 'cuprum/rails'

module Cuprum::Rails
  # Namespace for commands implementing Rails collection functionality.
  module Commands
    autoload :AssignOne, 'cuprum/rails/commands/assign_one'
  end
end
