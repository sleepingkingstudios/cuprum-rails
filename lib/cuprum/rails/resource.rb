# frozen_string_literal: true

require 'cuprum/rails'
require 'cuprum/rails/collection'

module Cuprum::Rails
  # Value object representing a controller resource.
  class Resource
    # @param collection [Cuprum::Collections::Base] Collection representing the
    #   resource data.
    # @param options [Hash] Additional options for the resource.
    # @param resource_class [Class] Class representing the resource items.
    # @param resource_name [String] The name of the resource.
    # @param routes [Cuprum::Rails::Routes] The routes defined for the resource.
    # @param singular [Boolean] Indicates that the resource is a singular
    #   collection, and has only one member.
    #
    # @option options default_order [Hash] The default ordering for the resource
    #   items.
    # @option options permitted_attributes [Array] List of attributes that can
    #   be set or changed by resourceful actions.
    # @option options primary_key [String, Symbol] The name of the primary key
    #   for the resource, if any.
    # @option options singular_resource_name [String] The singular form of the
    #   resource name.
    def initialize( # rubocop:disable Metrics/ParameterLists
      collection:     nil,
      resource_class: nil,
      resource_name:  nil,
      routes:         nil,
      singular:       false,
      **options
    )
      unless resource_class || resource_name
        raise ArgumentError, 'missing keyword :resource_class or :resource_name'
      end

      validate_permitted_attributes(options[:permitted_attributes])

      @options        = options
      @resource_class = resource_class
      @resource_name  = resource_name.to_s unless resource_name.nil?
      @routes         = routes
      @singular       = !!singular # rubocop:disable Style/DoubleNegation
      @collection     = collection || build_collection
    end

    # @return [Cuprum::Collections::Base] collection representing the resource
    #   data.
    attr_reader :collection

    # @return [Hash] additional options for the resource.
    attr_reader :options

    # @return [Class] class representing the resource items.
    attr_reader :resource_class

    # @return [String] the base url for the resource.
    def base_path
      @base_path ||=
        options
          .fetch(:base_path) { "/#{resource_name.underscore}" }
          .to_s
    end

    # @return [Hash] the default ordering for the resource items.
    def default_order
      @default_order ||= options.fetch(:default_order, {})
    end

    # @return [Array] list of attributes that can be set or changed by
    #   resourceful actions.
    def permitted_attributes
      @permitted_attributes ||= options.fetch(:permitted_attributes, nil)
    end

    # @return [Boolean] true if the collection is a plural collection, otherwise
    #   false.
    def plural?
      !@singular
    end

    # @return [String] the name of the primary key for the resource, if any.
    def primary_key
      @primary_key ||=
        options
          .fetch(:primary_key) { resource_class&.primary_key }
          .yield_self { |value| value.nil? ? nil : value.to_s }
    end

    # @return [String] the name of the resource.
    def resource_name
      return @resource_name if @resource_name

      name = resource_class.name.split('::').last.underscore

      @resource_name = plural? ? name.pluralize : name
    end

    # Generates the routes for the resource and injects the given wildcards.
    #
    # @param wildcards [Hash] The wildcard values to use in the routes.
    #
    # @return [Cuprum::Rails::Routes] the routes with injected wildcards.
    def routes(wildcards: {})
      routes_without_wildcards.with_wildcards(wildcards)
    end

    # @return [Boolean] true if the collection is a singular collection,
    #   otherwise false.
    def singular?
      @singular
    end

    # @return [String] the singular form of the resource name.
    def singular_resource_name
      @singular_resource_name ||=
        options
          .fetch(:singular_resource_name) do
            resource_name.singularize
          end
          .to_s
    end

    def validate_permitted_attributes(attributes)
      return if attributes.nil? || attributes.is_a?(Array)

      raise ArgumentError,
        'keyword :permitted_attributes must be an Array or nil',
        caller(1..-1)
    end

    private

    def build_collection
      return unless resource_class

      Cuprum::Rails::Collection.new(
        collection_name: resource_name,
        member_name:     singular_resource_name,
        record_class:    resource_class
      )
    end

    def routes_without_wildcards
      return @routes if @routes

      @routes =
        if plural?
          Cuprum::Rails::Routing::PluralRoutes.new(base_path: base_path)
        else
          Cuprum::Rails::Routing::SingularRoutes.new(base_path: base_path)
        end
    end
  end
end
