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
    autoload :Collection, 'cuprum/rails/collection'
    autoload :Command,    'cuprum/rails/command'
    autoload :Commands,   'cuprum/rails/commands'
    autoload :Query,      'cuprum/rails/query'
    autoload :Resource,   'cuprum/rails/resource'
  end
end
