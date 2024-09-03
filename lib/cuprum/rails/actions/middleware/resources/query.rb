# frozen_string_literal: true

require 'cuprum/collections/commands/associations/find_many'

require 'cuprum/rails/actions/middleware/resources'
require 'cuprum/rails/result'

module Cuprum::Rails::Actions::Middleware::Resources
  # Abstract middleware for performing a resource query.
  class Query < Cuprum::Rails::Action
    include Cuprum::Middleware

    # @param resource_params [Hash] parameters to pass to the resource.
    def initialize(**resource_params)
      super()

      @resource = build_resource(**resource_params)
    end

    # @return [Cuprum::Collections::Resource] the resource.
    attr_reader :resource

    private

    attr_reader :repository

    attr_reader :request

    attr_reader :result

    def build_resource(**params)
      Cuprum::Collections::Resource.new(**params)
    end

    def collection
      repository.find_or_create(
        name:           resource.name,
        qualified_name: resource.qualified_name
      )
    end

    def merge_result(result:, values:)
      return result unless result.value.is_a?(Hash)

      Cuprum::Rails::Result.new(
        **result.properties,
        value: merge_values(
          value:  result.value,
          values:
        )
      )
    end

    def merge_values(value:, values:)
      key = pluralize_name(resource:, values:)

      value.merge(key => values)
    end

    def pluralize_name(resource:, values:)
      values.is_a?(Array) ? resource.plural_name : resource.singular_name
    end

    def process(next_command, repository:, request:, **rest)
      @repository = repository
      @request    = request
      @result     = next_command.call(
        repository:,
        request:,
        resource:,
        **rest
      )
    end

    def perform_query
      if resource.singular?
        values = step { query_command.call(limit: 1) }

        success(values.first)
      else
        values = step { query_command.call }

        success(values.to_a)
      end
    end

    def query_command
      collection.find_matching
    end
  end
end
