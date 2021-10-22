# frozen_string_literal: true

require 'cuprum/rails/serializers/json'
require 'cuprum/rails/serializers/json/serializer'

module Cuprum::Rails::Serializers::Json
  # Converts Hash data structures to JSON based on configured serializers.
  class HashSerializer < Cuprum::Rails::Serializers::Json::Serializer
    # Converts the hash to JSON using the given serializers.
    #
    # First, #call finds the best serializer from the :serializers Hash for each
    # value in the Hash. This is done by walking up the object class's ancestors
    # to find the closest ancestor which is a key in the :serializers Hash.
    # The corresponding value is then called with the object, and the results
    # are combined into a new Hash and returned.
    #
    # @param hash [Hash<String, Object>] The hash to convert to JSON.
    # @param serializers [Hash<Class, #call>] The serializers for different
    #   object types.
    #
    # @return [Hash] a JSON-compatible representation of the hash.
    #
    # @raise UndefinedSerializerError if there is no matching serializer for
    #   any of the values in the hash.
    def call(hash, serializers:)
      unless hash.is_a?(Hash) && hash.keys.all? { |key| key.is_a?(String) }
        raise ArgumentError, 'object must be a Hash with String keys'
      end

      hash.each.with_object({}) do |(key, value), mapped|
        mapped[key] = super(value, serializers: serializers)
      end
    end

    private

    def handle_recursion!(_object)
      # Call serializes the values, not the hash. Because the context changes,
      # we don't need to check for recursion (unless the Hash contains itself,
      # in which case here there be dragons).
      yield
    end
  end
end
