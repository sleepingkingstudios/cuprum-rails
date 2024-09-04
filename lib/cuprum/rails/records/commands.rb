# frozen_string_literal: true

require 'cuprum/rails'

module Cuprum::Rails::Records
  # Namespace for commands implementing Records collection functionality.
  module Commands
    autoload :AssignOne,    'cuprum/rails/records/commands/assign_one'
    autoload :BuildOne,     'cuprum/rails/records/commands/build_one'
    autoload :DestroyOne,   'cuprum/rails/records/commands/destroy_one'
    autoload :FindMany,     'cuprum/rails/records/commands/find_many'
    autoload :FindMatching, 'cuprum/rails/records/commands/find_matching'
    autoload :FindOne,      'cuprum/rails/records/commands/find_one'
    autoload :InsertOne,    'cuprum/rails/records/commands/insert_one'
    autoload :UpdateOne,    'cuprum/rails/records/commands/update_one'
    autoload :ValidateOne,  'cuprum/rails/records/commands/validate_one'
  end
end
