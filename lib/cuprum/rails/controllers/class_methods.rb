# frozen_string_literal: true

require 'cuprum/rails/controllers'

module Cuprum::Rails::Controllers
  # Namespace for controller class-specific functionality.
  module ClassMethods
    autoload :Actions,
      'cuprum/rails/controllers/class_methods/actions'
    autoload :Configuration,
      'cuprum/rails/controllers/class_methods/configuration'
    autoload :Validations,
      'cuprum/rails/controllers/class_methods/validations'
  end
end
