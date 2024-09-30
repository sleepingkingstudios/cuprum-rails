# frozen_string_literal: true

require 'cuprum/collections/basic/repository'
require 'cuprum/collections/resource'

require 'cuprum/rails/actions'

module Cuprum::Rails::Actions
  # Namespace for actions that implement REST resource actions.
  module Resources
    autoload :Concerns, 'cuprum/rails/actions/resources/concerns'
    autoload :Index,    'cuprum/rails/actions/resources/index'
  end
end
