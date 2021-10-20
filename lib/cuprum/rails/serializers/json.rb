# frozen_string_literal: true

require 'cuprum/rails/serializers'

module Cuprum::Rails::Serializers
  # Namespace for JSON serializers, which convert objects to a JSON format.
  module Json
    autoload :ArraySerializer,
      'cuprum/rails/serializers/json/array_serializer'
    autoload :HashSerializer,
      'cuprum/rails/serializers/json/hash_serializer'
    autoload :IdentitySerializer,
      'cuprum/rails/serializers/json/identity_serializer'
    autoload :Serializer, 'cuprum/rails/serializers/json/serializer'
  end
end
