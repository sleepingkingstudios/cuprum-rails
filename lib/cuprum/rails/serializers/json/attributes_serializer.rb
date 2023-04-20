# frozen_string_literal: true

require 'cuprum/rails/serializers/base_serializer'
require 'cuprum/rails/serializers/json'

module Cuprum::Rails::Serializers::Json
  # @todo
  class AttributesSerializer < Cuprum::Rails::Serializers::Json::PropertiesSerializer # rubocop:disable Layout/LineLength
    @abstract_class = true

    class << self
      # @todo
      def attribute(name, serializer: nil, &block)
        property(
          name,
          scope:      name,
          serializer: serializer,
          &block
        )
      end

      # @todo
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
