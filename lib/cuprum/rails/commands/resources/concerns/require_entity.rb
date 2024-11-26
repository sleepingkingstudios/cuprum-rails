# frozen_string_literal: true

require 'cuprum/collections/errors/not_found'
require 'cuprum/collections/errors/not_unique'

require 'cuprum/rails/commands/resources/concerns'

module Cuprum::Rails::Commands::Resources::Concerns
  # Helper method for finding a required entity object.
  module RequireEntity
    private

    def entity_not_found_error
      Cuprum::Collections::Errors::NotFound.new(
        collection_name: collection.name,
        query:           collection.query
      )
    end

    def entity_not_unique_error
      Cuprum::Collections::Errors::NotUnique.new(
        collection_name: collection.name,
        query:           collection.query
      )
    end

    def find_entity(primary_key:)
      return collection.find_one.call(primary_key:) if require_primary_key?

      matching = step { collection.find_matching.call(limit: 2) }.to_a

      if matching.empty?
        failure(entity_not_found_error)
      elsif matching.size > 1
        failure(entity_not_unique_error)
      else
        matching.first
      end
    end

    def require_entity(entity: nil, primary_key: nil, **)
      return entity if entity

      find_entity(primary_key:)
    end

    def require_primary_key?
      resource.plural?
    end
  end
end
