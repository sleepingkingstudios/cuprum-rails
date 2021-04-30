# frozen_string_literal: true

require 'cuprum/rails'

module Cuprum::Rails
  # Namespace for commands implementing Rails collection functionality.
  module Commands
    autoload :AssignOne,  'cuprum/rails/commands/assign_one'
    autoload :BuildOne,   'cuprum/rails/commands/build_one'
    autoload :DestroyOne, 'cuprum/rails/commands/destroy_one'
    autoload :FindMany,   'cuprum/rails/commands/find_many'
  end
end
