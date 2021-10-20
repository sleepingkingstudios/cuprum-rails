# frozen_string_literal: true

require 'cuprum/rails/serializers/json'

module Cuprum::Rails::Serializers::Json
  # Converts objects or data structures to JSON based on configured serializers.
  class Serializer
    # Error class used when a serializer calls itself.
    class RecursiveSerializerError < StandardError; end

    # Error class used when there is no matching serializer for the object.
    class UndefinedSerializerError < StandardError; end

    # @return [Cuprum::Rails::Serializers::Json::Serializer] a cached instance
    #   of the serializer.
    def self.instance
      @instance ||= new
    end

    # Converts the object to JSON using the given serializers.
    #
    # First, #call finds the best serializer from the :serializers Hash. This is
    # done by walking up the object class's ancestors to find the closest
    # ancestor which is a key in the :serializers Hash. The corresponding value
    # is then called with the object.
    #
    # @param object [Object] The object to convert to JSON.
    # @param serializers [Hash<Class, #call>] The serializers for different
    #   object types.
    #
    # @return [Hash<String, Object>] a JSON-compatible Hash representation of
    #   the object.
    def call(object, serializers:)
      serializer = handle_recursion!(object) do
        serializer_for(object: object, serializers: serializers)
      end

      serializer.call(object, serializers: serializers)
    end

    private

    def handle_recursion!(object)
      serializer = yield

      return serializer unless instance_of?(serializer.class)

      raise RecursiveSerializerError,
        "invalid serializer for #{object.class.name} - recursive calls to" \
        " #{self.class.name}#call"
    end

    def serializer_for(object:, serializers:)
      object.class.ancestors.each do |ancestor|
        return serializers[ancestor] if serializers.key?(ancestor)
      end

      raise UndefinedSerializerError,
        "no serializer defined for #{object.class.name}"
    end
  end
end
