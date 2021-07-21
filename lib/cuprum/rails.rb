# frozen_string_literal: true

require 'cuprum'

# A Ruby implementation of the command pattern.
module Cuprum
  # An integration between Rails and the Cuprum library.
  module Rails
    # @return [String] The current version of the gem.
    def self.version
      VERSION
    end

    autoload :Action,     'cuprum/rails/action'
    autoload :Actions,    'cuprum/rails/actions'
    autoload :Collection, 'cuprum/rails/collection'
    autoload :Command,    'cuprum/rails/command'
    autoload :Commands,   'cuprum/rails/commands'
    autoload :Query,      'cuprum/rails/query'
    autoload :Responders, 'cuprum/rails/responders'
    autoload :Resource,   'cuprum/rails/resource'
    autoload :Routes,     'cuprum/rails/routes'
    autoload :Routing,    'cuprum/rails/routing'
  end
end
