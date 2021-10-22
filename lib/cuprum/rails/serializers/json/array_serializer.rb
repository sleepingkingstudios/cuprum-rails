# frozen_string_literal: true

require 'cuprum/rails/serializers/json'
require 'cuprum/rails/serializers/json/serializer'

module Cuprum::Rails::Serializers::Json
  # Converts Array data structures to JSON based on configured serializers.
  class ArraySerializer < Cuprum::Rails::Serializers::Json::Serializer
    # Converts the array to JSON using the given serializers.
    #
    # First, #call finds the best serializer from the :serializers Hash for each
    # item in the Array. This is done by walking up the object class's ancestors
    # to find the closest ancestor which is a key in the :serializers Hash. The
    # corresponding value is then called with the object, and the results are
    # combined into a new Array and returned.
    #
    # @param array [Array] The array to convert to JSON.
    # @param serializers [Hash<Class, #call>] The serializers for different
    #   object types.
    #
    # @return [Array] a JSON-compatible representation of the array.
    #
    # @raise UndefinedSerializerError if there is no matching serializer for
    #   any of the items in the array.
    def call(array, serializers:)
      raise ArgumentError, 'object must be an Array' unless array.is_a?(Array)

      array.map { |item| super(item, serializers: serializers) }
    end

    private

    def handle_recursion!(_object)
      # Call serializes the items, not the array. Because the context changes,
      # we don't need to check for recursion (unless the Array contains itself,
      # in which case here there be dragons).
      yield
    end
  end
end
