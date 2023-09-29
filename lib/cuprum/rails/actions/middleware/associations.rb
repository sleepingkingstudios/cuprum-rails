# frozen_string_literal: true

require 'cuprum/rails/actions/middleware'

module Cuprum::Rails::Actions::Middleware
  # Namespace for association middleware.
  module Associations
    autoload :Cache,  'cuprum/rails/actions/middleware/associations/cache'
    autoload :Parent, 'cuprum/rails/actions/middleware/associations/parent'
    autoload :Query,  'cuprum/rails/actions/middleware/associations/query'
  end
end
