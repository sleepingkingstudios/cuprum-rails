# frozen_string_literal: true

require 'cuprum/rails/serializers/base_serializer'
require 'cuprum/rails/serializers/json'

module Cuprum::Rails::Serializers::Json
  # Generates a JSON representation of the object's attributes.
  #
  # Defined properties are inherited from the parent serializer. This allows
  # you to extend existing serializers with additional functionality.
  #
  # @example Serializing an attribute.
  #   User = Struct.new(:first_name, :last_name, :salary, :department)
  #   class FirstNameSerializer < Cuprum::Rails::Serializers::Json::AttributesSerializer
  #     attribute :first_name
  #   end
  #
  #   user       = User.new('Alan', 'Bradley')
  #   serializer = FirstNameSerializer.new
  #   serializer.call(user, context: context)
  #   #=> {
  #     'first_name' => 'Alan'
  #   }
  #
  # @example Using a custom serializer.
  #   User = Struct.new(:first_name, :last_name, :salary, :department)
  #   class SalarySerializer < Cuprum::Rails::Serializers::Json::AttributesSerializer
  #     attribute :salary, serializer: BigDecimalSerializer
  #   end
  #
  #   user       = User.new('Alan', 'Bradley', BigDecimal('100000'))
  #   serializer = SalarySerializer.new
  #   serializer.call(user, context: context)
  #   #=> {
  #     'salary' => '0.1e6'
  #   }
  #
  # @example Using a custom mapping.
  #   User = Struct.new(:first_name, :last_name, :hire_date)
  #   class HireDateSerializer < Cuprum::Rails::Serializers::Json::AttributesSerializer
  #     attribute(:hire_date) { |value| value&.iso8601 }
  #   end
  #
  #   user       = User.new('Alan', 'Bradley', Date.new(1977, 5, 25))
  #   serializer = HireDateSerializer.new
  #   serializer.call(user, context: context)
  #   #=> {
  #     'hire_date' => '1977-05-25'
  #   }
  #
  # @example Serializing multiple attributes.
  #   User = Struct.new(:first_name, :last_name, :hire_date)
  #   class UserSerializer < Cuprum::Rails::Serializers::Json::AttributesSerializer
  #     attributes \
  #       :first_name,
  #       :last_name,
  #       hire_date: :iso8601
  #   end
  #
  #   user       = User.new('Alan', 'Bradley', Date.new(1977, 5, 25))
  #   serializer = HireDateSerializer.new
  #   serializer.call(user, context: context)
  #   #=> {
  #     'first_name' => 'Alan',
  #     'last_name'  => 'Bradley',
  #     'hire_date'  => '1977-05-25'
  #   }
  #
  # @see Cuprum::Rails::Serializers::Json::PropertiesSerializer
  class AttributesSerializer < Cuprum::Rails::Serializers::Json::PropertiesSerializer # rubocop:disable Layout/LineLength
    @abstract_class = true

    class << self
      # Registers the attribute to be serialized.
      #
      # @param name [String, Symbol] the name of the attribute to serialize.
      #   This will determine the hash key of the serialized value, as well as
      #   the base value to be serialized.
      # @param serializer [#call] the serializer used to serialize the value. If
      #   no serializer is given, the default serializer (if any) will be used.
      #
      # @yield If a block is given, the block is used to transform the attribute
      #   value prior to serialization.
      # @yieldparam value [Object] the attribute value.
      # @yieldreturn [Object] the transformed value.
      #
      # @raise AbstractSerializerError when attempting to define a serialized
      #   property on an abstract class.
      def attribute(name, serializer: nil, &block)
        property(
          name,
          scope:      name,
          serializer:,
          &block
        )
      end

      # Registers the attributes to be serialized.
      #
      # @param attribute_names [Array<String, Symbol>] the names of the
      #   attributes to serialize.
      # @param attribute_mappings [Hash{String, Symbol => #to_proc}] the names
      #   and mappings of additional attributes to serialize.
      #
      # @raise AbstractSerializerError when attempting to define a serialized
      #   property on an abstract class.
      def attributes(*attribute_names, **attribute_mappings)
        require_concrete_class!

        validate_property_names!(*attribute_names, *attribute_mappings.keys)
        validate_property_mappings!(*attribute_mappings.values)

        attribute_names.each { |name| attribute(name) }

        attribute_mappings.each { |name, mapping| attribute(name, &mapping) }
      end

      private

      def validate_property_mappings!(*mappings)
        mappings.each do |mapping|
          next if mapping.respond_to?(:to_proc)

          raise ArgumentError, 'property mapping must respond to #to_proc'
        end
      end

      def validate_property_names!(*names)
        names.each { |name| validate_property_name!(name) }
      end
    end

    private

    def allow_recursion?
      # Call serializes the attributes, not the object itself.
      true
    end
  end
end
