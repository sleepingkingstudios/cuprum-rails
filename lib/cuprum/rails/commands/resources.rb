# frozen_string_literal: true

require 'cuprum/rails/commands'

module Cuprum::Rails::Commands
  # Namespace for commands that implement resourceful controller actions.
  module Resources
    autoload :Concerns, 'cuprum/rails/commands/resources/concerns'
    autoload :Create,   'cuprum/rails/commands/resources/create'
    autoload :Destroy,  'cuprum/rails/commands/resources/destroy'
    autoload :Edit,     'cuprum/rails/commands/resources/edit'
    autoload :Index,    'cuprum/rails/commands/resources/index'
    autoload :New,      'cuprum/rails/commands/resources/new'
    autoload :Show,     'cuprum/rails/commands/resources/show'
    autoload :Update,   'cuprum/rails/commands/resources/update'
  end
end
