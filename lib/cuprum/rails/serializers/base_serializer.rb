# frozen_string_literal: true

require 'cuprum/rails/serializers'

module Cuprum::Rails::Serializers
  # Converts objects or data structures based on configured serializers.
  class BaseSerializer
    # Error class used when a serializer calls itself.
    class RecursiveSerializerError < StandardError; end

    # Error class used when there is no matching serializer for the object.
    class UndefinedSerializerError < StandardError; end

    # @return [Cuprum::Rails::Serializers::Serializer] a cached instance
    #   of the serializer.
    def self.instance
      @instance ||= new
    end

    # Converts the object to a serialized representation.
    #
    # First, #call finds the best serializer from the :serializers Hash. This is
    # done by walking up the object class's ancestors to find the closest
    # ancestor which is a key in the :serializers Hash. The corresponding value
    # is then called with the object.
    #
    # @param object [Object] The object to serialize.
    # @param context [Cuprum::Rails::Serializers::Context] The serialization
    #   context, which includes the configured serializers for attributes or
    #   collection items.
    #
    # @return [Object] a serialized representation of the object.
    #
    # @raise RecursiveSerializerError if the serializer would create an infinite
    #   loop, e.g. by calling itself.
    # @raise UndefinedSerializerError if there is no matching serializer for
    #   the object.
    def call(object, context:)
      handle_recursion!(object, context:)

      context.serialize(object)
    end

    private

    def allow_recursion?
      false
    end

    def handle_recursion!(object, context:)
      return if allow_recursion?

      return unless context.serializer_for(object).instance_of?(self.class)

      raise RecursiveSerializerError,
        "invalid serializer for #{object.class.name} - recursive calls to " \
        "#{self.class.name}#call"
    end
  end
end
