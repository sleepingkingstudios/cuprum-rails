# frozen_string_literal: true

require 'cuprum/rails/serializers'

module Cuprum::Rails::Serializers
  # Namespace for JSON serializers, which convert objects to a JSON format.
  module Json
    autoload :Serializer, 'cuprum/rails/serializers/json/serializer'
  end
end
