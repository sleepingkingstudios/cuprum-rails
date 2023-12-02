# frozen_string_literal: true

require 'cuprum/rails/errors'

module Cuprum::Rails::Errors
  # Error class when a database execution error occurs.
  class InvalidStatement < Cuprum::Error
    # Short string used to identify the type of error.
    TYPE = 'cuprum.rails.errors.invalid_statement'
  end
end
