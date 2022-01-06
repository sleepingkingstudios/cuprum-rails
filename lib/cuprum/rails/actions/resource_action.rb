# frozen_string_literal: true

require 'cuprum/rails/action'
require 'cuprum/rails/actions/resource_methods'

module Cuprum::Rails::Actions
  # Abstract base class for resourceful actions.
  class ResourceAction < Cuprum::Rails::Action
    include Cuprum::Rails::Actions::ResourceMethods
  end
end
