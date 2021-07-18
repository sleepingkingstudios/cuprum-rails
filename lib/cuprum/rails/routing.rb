# frozen_string_literal: true

require 'cuprum/rails'

module Cuprum::Rails
  # Namespace for routing-specific functionality.
  module Routing
    autoload :PluralRoutes,   'cuprum/rails/routing/plural_routes'
    autoload :SingularRoutes, 'cuprum/rails/routing/singular_routes'
  end
end
