# frozen_string_literal: true

require 'cuprum/rails'

module Cuprum::Rails
  # Namespace for controller-specific functionality.
  module Controllers
    autoload :Configuration, 'cuprum/rails/controllers/configuration'
    autoload :Middleware,    'cuprum/rails/controllers/middleware'
  end
end
