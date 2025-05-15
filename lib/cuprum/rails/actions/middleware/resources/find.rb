# frozen_string_literal: true

require 'cuprum/rails/actions/middleware/resources'
require 'cuprum/rails/actions/middleware/resources/query'

module Cuprum::Rails::Actions::Middleware::Resources
  # Middleware for querying a resource.
  class Find < Cuprum::Rails::Actions::Middleware::Resources::Query
    # @param resource_params [Hash] parameters to pass to the resource.
    # @param only_form_actions [Boolean] if true, does not query the resource
    #   for non-GET success results. Defaults to false.
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
    def initialize( # rubocop:disable Metrics/ParameterLists
      limit:             nil,
      offset:            nil,
      order:             nil,
      where:             nil,
      only_form_actions: false,
      **resource_params,
      &block
    )
      super(limit:, offset:, order:, where:, **resource_params, &block)

      @only_form_actions = !!only_form_actions
    end

    # @return [Boolean] if true, does not query the resource for non-GET success
    #   results.
    def only_form_actions?
      @only_form_actions
    end

    private

    def process(next_command, **)
      super

      return result if skip_query?

      values = step { perform_query }

      merge_result(result:, values:)
    end

    def skip_query?
      return false unless only_form_actions?

      return false if request.http_method.to_s.downcase == 'get'

      result.success?
    end
  end
end
