# frozen_string_literal: true

require 'cuprum/rails'

module Cuprum::Rails
  # Namespace for custom Cuprum::Rails error classes.
  module Errors
    autoload :InvalidParameters,
      'cuprum/rails/errors/invalid_parameters'
    autoload :MissingParameters,
      'cuprum/rails/errors/missing_parameters'
    autoload :MissingPrimaryKey,
      'cuprum/rails/errors/missing_primary_key'
    autoload :UndefinedPermittedAttributes,
      'cuprum/rails/errors/undefined_permitted_attributes'
  end
end
