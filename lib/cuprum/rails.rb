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

    autoload :Action,      'cuprum/rails/action'
    autoload :Actions,     'cuprum/rails/actions'
    autoload :Collection,  'cuprum/rails/collection'
    autoload :Constraints, 'cuprum/rails/constraints'
    autoload :Controller,  'cuprum/rails/controller'
    autoload :Controllers, 'cuprum/rails/controllers'
    autoload :Errors,      'cuprum/rails/errors'
    autoload :Query,       'cuprum/rails/query'
    autoload :Repository,  'cuprum/rails/repository'
    autoload :Request,     'cuprum/rails/request'
    autoload :Records,     'cuprum/rails/records'
    autoload :Responders,  'cuprum/rails/responders'
    autoload :Responses,   'cuprum/rails/responses'
    autoload :Resource,    'cuprum/rails/resource'
    autoload :Result,      'cuprum/rails/result'
    autoload :Routes,      'cuprum/rails/routes'
    autoload :Routing,     'cuprum/rails/routing'
    autoload :Serializers, 'cuprum/rails/serializers'
  end
end
