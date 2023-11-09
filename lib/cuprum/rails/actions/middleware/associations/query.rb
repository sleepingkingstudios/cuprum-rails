# frozen_string_literal: true

require 'cuprum/collections/associations/belongs_to'
require 'cuprum/collections/commands/associations/find_many'

require 'cuprum/rails/actions/middleware/associations'
require 'cuprum/rails/actions/middleware/associations/cache'
require 'cuprum/rails/result'

module Cuprum::Rails::Actions::Middleware::Associations
  # Abstract middleware for performing an association query.
  class Query < Cuprum::Rails::Action
    include Cuprum::Middleware

    # @param association_type [String, Symbol] the type of association.
    # @param association_params [Hash] parameters to pass to the association.
    def initialize(association_type: nil, **association_params)
      super()

      @association_type = association_type&.intern
      @association      = build_association(**association_params)
    end

    # @return [Cuprum::Collections::Association] the association.
    attr_reader :association

    # @return [String, Symbol] the type of association.
    attr_reader :association_type

    private

    attr_reader :repository

    attr_reader :request

    attr_reader :resource

    attr_reader :result

    def association_class
      case association_type
      when :belongs_to
        Cuprum::Collections::Associations::BelongsTo
      else
        Cuprum::Collections::Association
      end
    end

    def build_association(**params)
      association_class.new(**params)
    end

    def cache_association(entities:, values:)
      Cuprum::Rails::Actions::Middleware::Associations::Cache
        .new(association: association, resource: resource)
        .call(entities: entities, values: values)
    end

    def entities_from(result:)
      return unless result.value.is_a?(Hash)

      if result.value.key?(resource.singular_name)
        return result.value[resource.singular_name]
      end

      result.value[resource.name]
    end

    def merge_result(entities:, result:, values:)
      return result unless result.value.is_a?(Hash)

      Cuprum::Rails::Result.new(
        **result.properties,
        value: merge_values(
          entities: entities,
          value:    result.value,
          values:   values
        )
      )
    end

    def merge_values(entities:, value:, values:)
      if entities.present?
        key   = pluralize_name(resource: resource, values: entities)
        value = value.merge(key => entities)
      end

      if values.present?
        key   = pluralize_name(resource: association, values: values)
        value = value.merge(key => values)
      end

      value
    end

    def pluralize_name(resource:, values:)
      values.is_a?(Array) ? resource.plural_name : resource.singular_name
    end

    def process(next_command, repository:, request:, resource:, **rest)
      @repository = repository
      @request    = request
      @resource   = resource
      @result     = next_command.call(
        repository: repository,
        request:    request,
        resource:   resource,
        **rest
      )
    end

    def perform_query(keys: nil)
      keys ||= step { query_keys }

      if keys.is_a?(Array)
        query_command.call(keys: keys)
      else
        query_command.call(key: keys)
      end
    end

    def query_command
      Cuprum::Collections::Commands::Associations::FindMany.new(
        association: association,
        repository:  repository,
        resource:    resource
      )
    end

    def query_keys
      entities = entities_from(result: result)

      if entities.is_a?(Array)
        association.map_entities_to_keys(*entities)
      else
        association.map_entities_to_keys(entities).first
      end
    end
  end
end
