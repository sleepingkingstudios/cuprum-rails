# frozen_string_literal: true

require 'cuprum/rails/responders'
require 'cuprum/rails/serializers/base_serializer'
require 'cuprum/rails/serializers/context'

module Cuprum::Rails::Responders
  # Implements serializing a result value into response data.
  module Serialization
    # @param serializers [Hash<Class, Object>] The serializers for converting
    #   result values into serialized data.
    # @param options [Hash] Additional parameters for the responder.
    def initialize(serializers:, **options)
      super(**options)

      @serializers = serializers
    end

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
        serializers:
      )

      Cuprum::Rails::Serializers::BaseSerializer
        .instance
        .call(object, context:)
    end
  end
end
