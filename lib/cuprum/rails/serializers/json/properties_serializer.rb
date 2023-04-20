# frozen_string_literal: true

require 'cuprum/rails/serializers/base_serializer'
require 'cuprum/rails/serializers/json'

module Cuprum::Rails::Serializers::Json
  # Generates a JSON representation of the object's properties.
  #
  # Defined properties are inherited from the parent serializer. This allows
  # you to extend existing serializers with additional functionality.
  #
  # @example Serializing an existing property.
  #   User = Struct.new(:first_name, :last_name, :salary, :department)
  #   class FirstNameSerializer < Cuprum::Rails::Serializers::Json::PropertySerializer
  #     property :first_name, scope: :first_name
  #   end
  #
  #   user       = User.new('Alan', 'Bradley')
  #   serializer = FirstNameSerializer.new
  #   serializer.call(user, context: context)
  #   #=> {
  #     'first_name' => 'Alan'
  #   }
  #
  # @example Serializing a compound property.
  #   User = Struct.new(:first_name, :last_name, :salary, :department)
  #   class FullNameSerializer < Cuprum::Rails::Serializers::Json::PropertySerializer
  #     property :full_name do |user|
  #       "#{user.first_name} #{user.last_name}"
  #     end
  #   end
  #
  #   user       = User.new('Alan', 'Bradley')
  #   serializer = FullNameSerializer.new
  #   serializer.call(user, context: context)
  #   #=> {
  #     'full_name' => 'Alan Bradley'
  #   }
  #
  # @example Using a custom serializer.
  #   User = Struct.new(:first_name, :last_name, :salary, :department)
  #   class SalarySerializer < Cuprum::Rails::Serializers::Json::PropertySerializer
  #     property :salary,
  #       scope:      :salary,
  #       serializer: BigDecimalSerializer
  #   end
  #
  #   user       = User.new('Alan', 'Bradley', BigDecimal('100000'))
  #   serializer = SalarySerializer.new
  #   serializer.call(user, context: context)
  #   #=> {
  #     'salary' => '0.1e6'
  #   }
  #
  # @example Using a nested scope.
  #   Department = Struct.new(:name)
  #   User       = Struct.new(:first_name, :last_name, :salary, :department)
  #   class DepartmentSerializer < Cuprum::Rails::Serializers::Json::PropertySerializer
  #     property :department, scope: %i[department name]
  #   end
  #
  #   user       = User.new('Alan', 'Bradley', nil, Department.new('Engineering'))
  #   serializer = DepartmentSerializer.new
  #   serializer.call(user, context: context)
  #   #=> {
  #     'department' => 'Engineering'
  #   }
  class PropertiesSerializer < Cuprum::Rails::Serializers::BaseSerializer
    # Error class used when defining an attribute on an abstract class.
    class AbstractSerializerError < StandardError; end

    # Data class that configures how an attribute is serialized.
    SerializedProperty =
      Struct.new(:mapping, :name, :scope, :serializer, keyword_init: true) do
        def value_for(object)
          return object if scope.nil?

          return object.dig(*Array(scope)) if object.respond_to?(:dig)

          SleepingKingStudios::Tools::Toolbelt
            .instance
            .object_tools
            .dig(object, *Array(scope))
        end
      end

    @abstract_class = true

    class << self
      # Registers the property to be serialized.
      #
      # @param name [String, Symbol] the name of the property to serialize. This
      #   will determine the hash key of the serialized value.
      # @param serializer [#call] the serializer used to serialize the value. If
      #   no serializer is given, the default serializer (if any) will be used.
      # @param scope [String, Symbol, Array<String, Symbol>] the path to the
      #   value to serialize, if any.
      #
      # @yield If a block is given, the block is used to transform the scoped
      #   value prior to serialization.
      # @yieldparam value [Object] the scoped value.
      # @yieldreturn [Object] the transformed value.
      #
      # @raise AbstractSerializerError when attempting to define a serialized
      #   property on an abstract class.
      def property(name, serializer: nil, scope: nil, &block) # rubocop:disable Metrics/MethodLength
        require_concrete_class!
        validate_property_name!(name)
        validate_scope!(scope)
        validate_serializer!(serializer)

        prop_key   = name.intern
        serialized = SerializedProperty.new(
          mapping:    block || :itself.to_proc,
          name:       name.to_s,
          scope:      scope,
          serializer: serializer
        )
        own_properties[prop_key] = serialized

        prop_key
      end

      # @api private
      def properties
        ancestors
          .select do |ancestor|
            ancestor < Cuprum::Rails::Serializers::Json::PropertiesSerializer
          end # rubocop:disable Style/MultilineBlockChain
          .reverse_each
          .reduce({}) { |hsh, ancestor| hsh.merge(ancestor.own_properties) }
      end

      protected

      def own_properties
        @own_properties ||= {}
      end

      private

      attr_reader :abstract_class

      def require_concrete_class!
        return unless abstract_class

        message =
          "#{name} is an abstract class - create a subclass to serialize " \
          'properties'

        raise AbstractSerializerError, message, caller(1..-1)
      end

      def tools
        SleepingKingStudios::Tools::Toolbelt.instance
      end

      def validate_property_name!(name)
        tools.assertions.validate_name(name, as: 'property name')
      end

      def validate_scope!(scope) # rubocop:disable Metrics/MethodLength
        return if scope.nil?

        if scope.is_a?(Array)
          validate_scope_array!(scope)

          return
        end

        if scope.is_a?(String) || scope.is_a?(Symbol)
          tools.assertions.validate_name(scope, as: 'scope')

          return
        end

        raise ArgumentError,
          'scope is not a String, a Symbol, or an Array of Strings or Symbols'
      end

      def validate_scope_array!(scope)
        unless scope.all? { |item| item.is_a?(String) || item.is_a?(Symbol) }
          raise ArgumentError,
            'scope is not a String, a Symbol, or an Array of Strings or Symbols'
        end

        scope.each.with_index do |item, index|
          tools.assertions.validate_name(item, as: "scope item at #{index}")
        end
      end

      def validate_serializer!(serializer)
        return if serializer.nil?
        return if serializer.respond_to?(:call)

        raise ArgumentError, 'serializer does not respond to #call'
      end
    end

    # Serializes the object's properties as JSON.
    #
    # @param object [Object] The object to convert to JSON.
    # @param context [Cuprum::Rails::Serializers::Context] The serialization
    #   context, which includes the configured serializers for attributes or
    #   collection items.
    #
    # @return [Hash<String, Object] a JSON-compatible representation of the
    #   object's properties.
    def call(object, context:) # rubocop:disable Metrics/MethodLength
      return super(nil, context: context) if object.nil?

      self.class.properties.each_value.with_object({}) do |property, hsh|
        value      = property.value_for(object)
        mapped     = property.mapping.call(value) if property.mapping
        serialized =
          if property.serializer
            property.serializer.call(mapped, context: context)
          else
            super(mapped, context: context)
          end

        hsh[property.name] = serialized
      end
    end
  end
end
