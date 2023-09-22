# frozen_string_literal: true

require 'cuprum/rails'

module Cuprum::Rails
  # Namespace for defined resourceful actions.
  module Actions
    autoload :Create,              'cuprum/rails/actions/create'
    autoload :Destroy,             'cuprum/rails/actions/destroy'
    autoload :Edit,                'cuprum/rails/actions/edit'
    autoload :Index,               'cuprum/rails/actions/index'
    autoload :Middleware,          'cuprum/rails/actions/middleware'
    autoload :New,                 'cuprum/rails/actions/new'
    autoload :ParameterValidation, 'cuprum/rails/actions/parameter_validation'
    autoload :ResourceAction,      'cuprum/rails/actions/resource_action'
    autoload :ResourceMethods,     'cuprum/rails/actions/resource_methods'
    autoload :Show,                'cuprum/rails/actions/show'
    autoload :Update,              'cuprum/rails/actions/update'
  end
end
