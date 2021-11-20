# frozen_string_literal: true

require 'cuprum/rails/responders'
require 'cuprum/rails/serializers/context'

module Cuprum::Rails::Responders
  # Implements serializing a result value into response data.
  module Serialization
    # @param root_serializer [Class] The root serializer for serializing the
    #   result value.
    # @param serializers [Hash<Class, Object>] The serializers for converting
    #   result values into serialized data.
    # @param options [Hash] Additional parameters for the responder.
    def initialize(root_serializer:, serializers:, **options)
      super(**options)

      @root_serializer = root_serializer
      @serializers     = serializers
    end

    # @return [Object] the root serializer for serializing the result value.
    attr_reader :root_serializer

    # @return [Hash<Class, Object>] The serializers for converting result values
    #   into serialized data.
    attr_reader :serializers

    # Converts a result value into a serialized data structure.
    #
    # @param object [Object] The object to serialize.
    #
    # @return [Object] the serialized data.
    def serialize(object)
      context = Cuprum::Rails::Serializers::Context.new(
        serializers: serializers
      )

      root_serializer.call(object, context: context)
    end
  end
end
