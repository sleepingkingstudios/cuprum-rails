# frozen_string_literal: true

require 'cuprum/rails/serializers/json'
require 'cuprum/rails/serializers/json/serializer'

module Cuprum::Rails::Serializers::Json
  # Converts a Cuprum::Error to JSON using the #as_json method.
  class ErrorSerializer < Cuprum::Rails::Serializers::Json::Serializer
    # Converts the Cuprum error to JSON.
    #
    # Calls and returns the #as_json method of the error.
    #
    # @param error [Cuprum::Error] The error to convert to JSON.
    #
    # @return [Hash] a JSON-compatible representation of the error.
    def call(error, **_)
      unless error.is_a?(Cuprum::Error)
        raise ArgumentError, 'object must be a Cuprum::Error'
      end

      error.as_json
    end
  end
end
