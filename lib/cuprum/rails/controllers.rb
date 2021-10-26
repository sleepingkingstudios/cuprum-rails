# frozen_string_literal: true

require 'cuprum/rails'

module Cuprum::Rails
  # Namespace for controller-specific functionality.
  module Controllers
    autoload :Configuration, 'cuprum/rails/controllers/configuration'
  end
end
