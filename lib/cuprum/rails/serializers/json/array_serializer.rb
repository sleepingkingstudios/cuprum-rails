# frozen_string_literal: true

require 'cuprum/rails/serializers/json'
require 'cuprum/rails/serializers/json/serializer'

module Cuprum::Rails::Serializers::Json
  # Converts Array data structures to JSON based on configured serializers.
  class ArraySerializer < Cuprum::Rails::Serializers::Json::Serializer
    # Converts the object to JSON using the given serializers.
    #
    # @todo
    def call(array, serializers:)
      raise ArgumentError, 'object must be an Array' unless array.is_a?(Array)

      array.map { |item| super(item, serializers: serializers) }
    end

    private

    def handle_recursion!(_object)
      # Call serializes the items, not the array.
      yield
    end
  end
end
