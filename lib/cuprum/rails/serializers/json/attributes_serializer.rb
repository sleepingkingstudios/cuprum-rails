# frozen_string_literal: true

require 'cuprum/rails/serializers/json'
require 'cuprum/rails/serializers/json/serializer'

module Cuprum::Rails::Serializers::Json
  # @todo
  class AttributesSerializer < Cuprum::Rails::Serializers::Json::Serializer
    # Error class used when a serializer calls itself.
    class AbstractSerializerError < StandardError; end

    class << self
      # @todo
      def attribute(attr_name, serializer = nil, &block)
        validate_subclass!
        validate_attribute_name!(attr_name)
        validate_serializer!(serializer)

        own_attributes[attr_name.to_s] = serializer || block

        self
      end

      # @todo
      def attributes(*_, **_)
        all_attributes
      end

      protected

      def own_attributes
        @own_attributes ||= {}
      end

      private

      def all_attributes
        ancestors
          .select do |ancestor|
            ancestor < Cuprum::Rails::Serializers::Json::AttributesSerializer
          end # rubocop:disable Style/MultilineBlockChain
          .reverse_each
          .reduce({}) { |hsh, ancestor| hsh.merge(ancestor.own_attributes) }
      end

      def validate_attribute_name!(attr_name)
        raise ArgumentError, "attribute name can't be blank" if attr_name.nil?

        unless attr_name.is_a?(String) || attr_name.is_a?(Symbol)
          raise ArgumentError, 'attribute name must be a string or symbol'
        end

        return unless attr_name.empty?

        raise ArgumentError, "attribute name can't be blank"
      end

      def validate_serializer!(serializer)
        return if serializer.nil? || serializer.respond_to?(:call)

        raise ArgumentError, 'serializer must respond to #call'
      end

      def validate_subclass!
        unless self == Cuprum::Rails::Serializers::Json::AttributesSerializer
          return
        end

        raise AbstractSerializerError,
          'AttributesSerializer is an abstract class - create a subclass to' \
          ' define attributes'
      end
    end

    # @todo
    def call(object, serializers:)
      self.class.attributes.each.with_object({}) \
      do |(attr_name, serializer), hsh|
        attr_value     = object.send(attr_name)
        hsh[attr_name] =
          serialize_attribute(
            attr_value:  attr_value,
            serializer:  serializer,
            serializers: serializers
          ) { super(attr_value, serializers: serializers) }
      end
    end

    private

    def apply_block(attr_value, block:, serializers:)
      args   = block_argument?(block) ? [attr_value] : []
      kwargs = block_keyword?(block)  ? { serializers: serializers } : {}

      kwargs.empty? ? block.call(*args) : block.call(*args, **kwargs)
    end

    def block_argument?(block)
      block.parameters.any? { |type, _| type == :req || type == :rest } # rubocop:disable Style/MultipleComparison
    end

    def block_keyword?(block)
      block.parameters.any? do |type, name|
        (type == :keyreq && name == :serializers) || type == :keyrest
      end
    end

    def serialize_attribute(attr_value:, serializer:, serializers:)
      case serializer
      when Cuprum::Rails::Serializers::Json::Serializer
        serializer.call(attr_value)
      when Proc
        apply_block(attr_value, block: serializer, serializers: serializers)
      else
        yield
      end
    end
  end
end