# frozen_string_literal: true

require 'cuprum/collections/errors/not_found'
require 'cuprum/collections/errors/not_unique'

require 'cuprum/rails/commands'

module Cuprum::Rails::Commands
  # Utility command for finding a resourceful entity.
  class RequireEntity < Cuprum::Command
    # @param collection [Cuprum::Collection] the collection used to find the
    #   entity.
    # @param require_primary_key [true, false] if true, finds the entity using
    #   a :primary_key parameter, if given.
    def initialize(collection:, require_primary_key:)
      super()

      @collection          = collection
      @require_primary_key = require_primary_key
    end

    # @return [Cuprum::Collection] the collection used to find the entity.
    attr_reader :collection

    # @return [true, false] if true, finds the entity using a :primary_key
    #   parameter, if given.
    def require_primary_key?
      @require_primary_key
    end

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

    def find_matching_entity
      matching = step { collection.find_matching.call(limit: 2) }.to_a

      if matching.empty?
        failure(entity_not_found_error)
      elsif matching.size > 1
        failure(entity_not_unique_error)
      else
        matching.first
      end
    end

    def process(entity: nil, primary_key: nil, **)
      return entity if entity

      return collection.find_one.call(primary_key:) if require_primary_key?

      find_matching_entity
    end
  end
end
