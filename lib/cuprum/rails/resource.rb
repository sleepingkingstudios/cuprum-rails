# frozen_string_literal: true

require 'cuprum/collections/resource'

require 'cuprum/rails'
require 'cuprum/rails/collection'

module Cuprum::Rails
  # Value object representing a controller resource.
  class Resource < Cuprum::Collections::Resource
    # Default actions for a plural resource.
    PLURAL_ACTIONS = %w[create destroy edit index new show update].freeze

    # Default actions for a singular resource.
    SINGULAR_ACTIONS = %w[create destroy edit new show update].freeze

    STRING_COLUMN_TYPES = Set.new(%i[string uuid]).freeze
    private_constant :STRING_COLUMN_TYPES

    # @overload initialize(entity_class: nil, name: nil, qualified_name: nil, singular_name: nil, **options)
    #   @param entity_class [Class, String] the class of entity represented by
    #     the resource.
    #   @param name [String] the name of the resource.
    #   @param qualified_name [String] a scoped name for the resource.
    #   @param routes [Cuprum::Rails::Routes] the routes defined for the
    #     resource.
    #   @param singular_name [String] the name of an entity in the resource.
    #   @param options [Hash] additional options for the resource.
    #
    #   @option options actions [Array, Set] the defined actions for the
    #     resource.
    #   @option options base_path [String] the base url for the resource.
    #   @option options default_order [Hash] the default ordering for the
    #     resource items.
    #   @option options permitted_attributes [Array] list of attributes that can
    #     be set or changed by resourceful actions.
    #   @option options primary_key_name [String] the name of the primary key
    #     attribute. Defaults to 'id'.
    #   @option primary_key_type [Class, Stannum::Constraint] the type of
    #     the primary key attribute. Defaults to Integer.
    #   @option options plural [Boolean] if true, the resource represents a
    #     plural resource. Defaults to true. Can also be specified as :singular.
    #   @option primary_key_type [Class, Stannum::Constraint] the type of
    #     the primary key attribute. Defaults to Integer.
    def initialize(routes: nil, **params)
      validate_permitted_attributes(params[:permitted_attributes])

      super(**params)

      @routes = routes
    end

    # @return [Set] the defined actions for the resource.
    def actions
      @actions ||= Set.new(options.fetch(:actions, default_actions).map(&:to_s))
    end

    # @return [Array<Resource>] the resource's ancestors, starting with the
    #   resource itself.
    def ancestors
      each_ancestor.to_a
    end

    # @return [String] the base url for the resource.
    def base_path
      @base_path ||=
        options
          .fetch(:base_path) { default_base_path }
          .to_s
    end

    # Enumerates the resource's ancestors, starting with the resource itself.
    #
    # @yield_param [Resource] the current ancestor.
    def each_ancestor(&block)
      return enum_for(:each_ancestor) unless block_given?

      parent&.each_ancestor(&block)

      yield self
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

    # @return [String] the name of the primary key attribute. Defaults to 'id'.
    def primary_key_name
      @primary_key_name ||=
        options
          .fetch(:primary_key_name) { entity_class.primary_key }
          .to_s
    end
    alias primary_key primary_key_name

    # @return [Cuprum::Rails::Resource] the parent resource, if any.
    def parent
      @parent ||= @options.fetch(:parent, nil)
    end

    # @return [Class, Stannum::Constraint] the type of the primary key
    #   attribute. Defaults to Integer.
    def primary_key_type
      @primary_key_name =
        options
          .fetch(:primary_key_type) do
            key    = entity_class.primary_key
            column = entity_class.columns.find { |col| col.name == key }

            STRING_COLUMN_TYPES.include?(column.type) ? String : Integer
          end # rubocop:disable Style/MultilineBlockChain
          .then { |value| value.is_a?(String) ? value.constantize : value }
    end

    # Generates the routes for the resource and injects the given wildcards.
    #
    # @param wildcards [Hash] The wildcard values to use in the routes.
    #
    # @return [Cuprum::Rails::Routes] the routes with injected wildcards.
    def routes(wildcards: {})
      routes_without_wildcards.with_wildcards(wildcards)
    end

    private

    def default_actions
      singular? ? SINGULAR_ACTIONS : PLURAL_ACTIONS
    end

    def default_base_path
      "#{parent_path}/#{(singular? ? name.singularize : name).underscore}"
    end

    def default_parent_path
      return unless parent

      return parent.base_path if parent.singular?

      "#{parent.base_path}/:#{parent.singular_name}_id"
    end

    def parent_path
      @parent_path || default_parent_path
    end

    def routes_options
      {
        base_path:   base_path,
        parent_path: parent_path
      }
    end

    def routes_without_wildcards
      return @routes if @routes

      @routes =
        if plural?
          Cuprum::Rails::Routing::PluralRoutes.new(**routes_options)
        else
          Cuprum::Rails::Routing::SingularRoutes.new(**routes_options)
        end
    end

    def validate_permitted_attributes(attributes)
      return if attributes.nil? || attributes.is_a?(Array)

      raise ArgumentError,
        'keyword :permitted_attributes must be an Array or nil',
        caller(1..-1)
    end
  end
end
