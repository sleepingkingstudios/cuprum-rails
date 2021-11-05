# frozen_string_literal: true

require 'cuprum/rails/serializers/json'
require 'cuprum/rails/serializers/json/serializer'

module Cuprum::Rails::Serializers::Json
  # Converts the object to JSON by serializing the specified attributes.
  #
  # When called, the serializer will convert each of the given attributes to
  # JSON using the given serializers.
  #
  # Defined attributes are inherited from the parent serializer. This allows you
  # to extend existing serializers with additional functionality.
  #
  # @example Defining A Base Serializer
  #   class RecordSerializer < Cuprum::Rails::Serializers::Json::AttributesSerializer # rubocop:disable Layout/LineLength
  #     attribute :id
  #   end
  #
  #   book        = Book.new(
  #     id:           10,
  #     title:        'Gideon the Ninth',
  #     author:       'Tamsyn Muir',
  #     published_at: '2019-09-10'
  #   )
  #   serializers = Cuprum::Rails::Serializers::Json.default_serializers
  #
  #   RecordSerializer.new.call(book, serializers: serializers)
  #   #=> { id: 10 }
  #
  # @example Defining A Record Serializer
  #   class BookSerializer < RecordSerializer
  #     attribute :title, Cuprum::Rails::Serializers::Json::IdentitySerializer.instance # rubocop:disable Layout/LineLength
  #     attribute :author do |author|
  #       "by: #{author}"
  #     end
  #   end
  #
  #   BookSerializer.new.call(book, serializers: serializers)
  #   #=> {
  #         id:     10,
  #         title:  'Gideon the Ninth',
  #         author: 'by: Tamsyn Muir'
  #       }
  #
  # @example Defining a Serializer Subclass
  #   class PublishedBookSerializer < BookSerializer
  #     attribute :published_at
  #   end
  #
  #   PublishedBookSerializer.new.call(book, serializers: serializers)
  #   #=> {
  #         id:           10,
  #         title:        'Gideon the Ninth',
  #         author:       'by: Tamsyn Muir',
  #         published_at: '2019-09-10'
  #       }
  class AttributesSerializer < Cuprum::Rails::Serializers::Json::Serializer
    # Error class used when a serializer calls itself.
    class AbstractSerializerError < StandardError; end

    class << self
      # Registers the attribute to be serialized.
      #
      # This class method will raise an AbstractSerializerError if called on
      # AttributesSerializer directly. Instead, create a subclass and define
      # attributes on that subclass.
      #
      # @return [Class] the serializer class.
      #
      # @raise [AbstractSerializerError] if called on AttributesSerializer.
      #
      # @see AttributesSerializer#call.
      #
      # @overload attribute(attr_name)
      #   Registers the attribute for serialization. When the serializer is
      #   called, the value of the attribute will be converted to JSON using the
      #   serializers passed to #call.
      #
      #   @param attr_name [String, Symbol] The name of the attribute to
      #     serialize.
      #
      # @overload attribute(attr_name, serializer)
      #   Registers the attribute for serialization. When the serializer is
      #   called, the given serializer will be called with the value of the
      #   attribute and the configured serializers.
      #
      #   @param attr_name [String, Symbol] The name of the attribute to
      #     serialize.
      #   @param serializer [Cuprum::Rails::Serializers::Json::Serializer] the
      #     serializer to use when converting the attribute to JSON.
      #
      # @overload attribute(attr_name, &block)
      #   Registers the attribute for serialization. When the serializer is
      #   called, the block will be called with the value of the attribute and
      #   the configured serializers.
      #
      #   @param attr_name [String, Symbol] The name of the attribute to
      #     serialize.
      #
      #   @yield The value of the attribute and the configured serializers.
      #
      #   @yieldreturn the attribute value converted to JSON.
      def attribute(attr_name, serializer = nil, &block)
        validate_subclass!
        validate_attribute_name!(attr_name)
        validate_serializer!(serializer)

        own_attributes[attr_name.to_s] = serializer || block

        self
      end

      # @return [Hash<String, Object>] the defined attributes and respective
      #   serializers.
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

    # Converts the defined attributes to JSON.
    #
    # @param object [Object] The object to convert to JSON.
    # @param serializers [Hash<Class, #call>] The serializers for different
    #   object types.
    #
    # @return [Hash<String, Object] a JSON-compatible representation of the
    #   object's attributes.
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
