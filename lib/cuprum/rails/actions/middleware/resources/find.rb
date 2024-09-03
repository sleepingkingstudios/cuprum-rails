# frozen_string_literal: true

require 'cuprum/rails/actions/middleware/resources'
require 'cuprum/rails/actions/middleware/resources/query'

module Cuprum::Rails::Actions::Middleware::Resources
  # Middleware for querying a resource.
  class Find < Cuprum::Rails::Actions::Middleware::Resources::Query
    # @param only_form_actions [Boolean] if true, does not query the resource
    #   for non-GET success results. Defaults to false.
    # @param resource_params [Hash] parameters to pass to the resource.
    def initialize(only_form_actions: false, **resource_params)
      super(**resource_params)

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
