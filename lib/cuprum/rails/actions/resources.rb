# frozen_string_literal: true

require 'cuprum/collections/basic/repository'
require 'cuprum/collections/resource'

require 'cuprum/rails/actions'

module Cuprum::Rails::Actions
  # Namespace for actions that implement REST resource actions.
  module Resources
    autoload :Action,   'cuprum/rails/actions/resources/action'
    autoload :Concerns, 'cuprum/rails/actions/resources/concerns'
    autoload :Create,   'cuprum/rails/actions/resources/create'
    autoload :Destroy,  'cuprum/rails/actions/resources/destroy'
    autoload :Edit,     'cuprum/rails/actions/resources/edit'
    autoload :Index,    'cuprum/rails/actions/resources/index'
    autoload :New,      'cuprum/rails/actions/resources/new'
    autoload :Show,     'cuprum/rails/actions/resources/show'
    autoload :Update,   'cuprum/rails/actions/resources/update'
  end
end
