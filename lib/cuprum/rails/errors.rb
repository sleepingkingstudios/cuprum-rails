# frozen_string_literal: true

require 'cuprum/rails'

module Cuprum::Rails
  # Namespace for custom Cuprum::Rails error classes.
  module Errors
    autoload :InvalidParameters, 'cuprum/rails/errors/invalid_parameters'
    autoload :ResourceError,     'cuprum/rails/errors/resource_error'
  end
end
