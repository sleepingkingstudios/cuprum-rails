# frozen_string_literal: true

require 'cuprum/collections/commands/associations/find_many'
require 'cuprum/collections/scope'

require 'cuprum/rails/actions/middleware/resources'
require 'cuprum/rails/result'

module Cuprum::Rails::Actions::Middleware::Resources
  # Abstract middleware for performing a resource query.
  class Query < Cuprum::Rails::Action
    include Cuprum::Middleware

    # @param resource_params [Hash] parameters to pass to the resource.
    # @param limit [Integer] the maximum number of results to return.
    # @param offset [Integer] the initial ordered items to skip.
    # @param order [Array<String, Symbol>, Hash<{String, Symbol => Symbol}>]
    #   the sort order of the returned items. Should be either an array of
    #   attribute names or a hash of attribute names and directions.
    # @param where [Hash, Cuprum::Collections::Scope] additional filters for
    #   selecting data. The middleware will only return data matching these
    #   filters.
    #
    # @yield builds a scope to filter the returned data.
    # @yieldparam [Cuprum::Collections::Scopes::Criteria::Parser::BlockParser]
    #   parser object for generating the query scope.
    # @yieldreturn [Hash] the generated scope hash.
    #
    # @see Cuprum::Rails::Resource#initialize
    def initialize(
      limit:  nil,
      offset: nil,
      order:  nil,
      where:  nil,
      **resource_params,
      &block
    )
      super()

      where ||= Cuprum::Collections::Scope.new(&block) if block_given?

      @resource     = build_resource(**resource_params)
      @query_params = { limit:, offset:, order:, where: }.compact
    end

    # @return [Hash] options passed to the query.
    attr_reader :query_params

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
      repository.find(
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
        values = step { query_command.call(**query_params, limit: 1) }

        success(values.first)
      else
        values = step { query_command.call(**query_params) }

        success(values.to_a)
      end
    end

    def query_command
      collection.find_matching
    end
  end
end
