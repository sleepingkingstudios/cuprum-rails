# frozen_string_literal: true

require 'cuprum/rails/actions/middleware/associations'
require 'cuprum/rails/actions/middleware/associations/query'

module Cuprum::Rails::Actions::Middleware::Associations
  # Middleware for querying an association from the action results.
  class Find < Cuprum::Rails::Actions::Middleware::Associations::Query
    private

    def process(next_command, repository:, request:, resource:, **rest)
      super

      return result unless result.success?

      values   = step { perform_query }
      entities = entities_from(result:)
      entities = step { cache_association(entities:, values:) }

      merge_result(entities:, result:, values:)
    end
  end
end
