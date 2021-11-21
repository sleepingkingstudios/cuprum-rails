# frozen_string_literal: true

require 'cuprum/rails/serializers'

module Cuprum::Rails::Serializers
  # Encapsulates and applies configuration for performing serialization.
  class Context
    # Error class used when there is no matching serializer for the object.
    class UndefinedSerializerError < StandardError; end

    # @param serializers [Hash<Class, Object>] The configured serializers for
    #   different object types.
    def initialize(serializers:)
      @serializers = serializers
    end

    # @return [Hash<Class, Object>] The configured serializers for different
    #   object types.
    attr_reader :serializers

    # Finds and calls the configured serializer for the given object.
    #
    # @param object [Object] The object to serialize.
    #
    # @return [Object] the serialized representation of the object.
    #
    # @raise [UndefinedSerializerError] if there is no configured serializer for
    #   the object.
    #
    # @see #serializer_for
    def serialize(object)
      serializer_for(object).call(object, context: self)
    end

    # Finds and initializes the configured serializer for the given object.
    #
    # If the configured serializer is a Class and responds to the .instance
    # class method, then #serializer_for will return the value of .instance. If
    # the configured serializer is a Class but does not respond to .instance, a
    # new instance of the serializer class will be created using .new and
    # returned. If the configured serializer is not a Class, #serializer_for
    # will return the configured serializer.
    #
    # The return value is cached across multiple calls to #serializer_for.
    #
    # @param object [Object] The object to serialize.
    #
    # @return [Object] the serializer instance for that object.
    #
    # @raise [UndefinedSerializerError] if there is no configured serializer for
    #   the object.
    def serializer_for(object)
      (@cached_serializers ||= {})[object.class] ||= find_serializer_for(object)
    end

    private

    def find_serializer_class_for(object)
      object.class.ancestors.each do |ancestor|
        configured = serializers[ancestor]

        return configured if configured
      end

      nil
    end

    def find_serializer_for(object)
      configured = find_serializer_class_for(object)

      if configured.nil?
        raise UndefinedSerializerError,
          "no serializer defined for #{object.class.name}",
          caller(1..-1)
      end

      return configured unless configured.is_a?(Class)

      return configured.instance if configured.respond_to?(:instance)

      configured.new
    end
  end
end
