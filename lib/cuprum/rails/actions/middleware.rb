# frozen_string_literal: true

require 'cuprum/rails/actions'

module Cuprum::Rails::Actions
  # Namespace for action middleware, which wraps controller actions.
  module Middleware
    autoload :Associations, 'cuprum/rails/actions/middleware/associations'
    autoload :Resources,    'cuprum/rails/actions/middleware/resources'
  end
end
