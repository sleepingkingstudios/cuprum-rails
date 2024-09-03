# frozen_string_literal: true

require 'cuprum/collections/commands/associations/require_many'

require 'cuprum/rails/actions/middleware/associations'
require 'cuprum/rails/actions/middleware/associations/query'
require 'cuprum/rails/errors/missing_parameter'

module Cuprum::Rails::Actions::Middleware::Associations
  # Middleware for querying a parent association from a parameter.
  class Parent < Cuprum::Rails::Actions::Middleware::Associations::Query
    # @param association_params [Hash] parameters to pass to the association.
    def initialize(**association_params)
      super(
        association_type: :belongs_to,
        **association_params
      )
    end

    private

    def cache_entities(result:, values:)
      return unless result.success?

      entities = entities_from(result:)

      cache_association(entities:, values:)
    end

    def process(next_command, repository:, request:, resource:, **rest)
      @repository = repository
      @request    = request
      @resource   = resource

      primary_key = step { query_keys }
      values      = step { require_parent(primary_key:) }
      result      = super
      entities    = step { cache_entities(result:, values:) }

      merge_result(entities:, result:, values:)
    end

    def query_command
      Cuprum::Collections::Commands::Associations::RequireMany.new(
        association:,
        repository:,
        resource:
      )
    end

    def query_keys
      key   = "#{association.singular_name}_id"
      value = request.params[key]

      return value if value.present?

      error = Cuprum::Rails::Errors::MissingParameter.new(
        parameter_name: key,
        parameters:     request.params
      )
      failure(error)
    end

    def require_parent(primary_key:)
      values = step { perform_query(keys: primary_key) }

      values.is_a?(Array) ? values.first : values
    end
  end
end
