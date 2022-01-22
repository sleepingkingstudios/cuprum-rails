# frozen_string_literal: true

require 'cuprum/rails/serializers/base_serializer'
require 'cuprum/rails/serializers/json'

module Cuprum::Rails::Serializers::Json
  # Serializer that returns a value object as itself.
  class IdentitySerializer < Cuprum::Rails::Serializers::BaseSerializer
    # Returns the object.
    #
    # This serializer should only be used with value objects: nil, true, false,
    # Integers, Floats, and Strings.
    #
    # @param object [Object] The object to convert to JSON.
    #
    # @return [Object] a JSON representation of the object.
    def call(object, **_)
      object
    end
  end
end
