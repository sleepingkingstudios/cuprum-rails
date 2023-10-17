# frozen_string_literal: true

require 'cuprum/rails/actions/middleware'

module Cuprum::Rails::Actions::Middleware
  # Namespace for resource middleware.
  module Resources
    autoload :Find,  'cuprum/rails/actions/middleware/resources/find'
    autoload :Query, 'cuprum/rails/actions/middleware/resources/query'
  end
end
