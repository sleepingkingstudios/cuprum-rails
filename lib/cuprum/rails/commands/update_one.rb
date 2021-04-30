# frozen_string_literal: true

require 'cuprum/collections/errors/not_found'

require 'cuprum/rails/command'
require 'cuprum/rails/commands'

module Cuprum::Rails::Commands
  # Command for updating an ActiveRecord record in the collection.
  class UpdateOne < Cuprum::Rails::Command
    # @!method call(entity:)
    #   Updates the record in the collection.
    #
    #   If the collection does not already have a record with the same primary
    #   key, #call will fail and the collection will not be updated.
    #
    #   @param entity [ActiveRecord::Base] The collection record to persist.
    #
    #   @return [Cuprum::Result<ActiveRecord::Base>] the persisted record.
    validate_parameters :call do
      keyword :entity, Object
    end

    private

    def handle_missing_record(primary_key:)
      query = record_class.where(primary_key_name => primary_key)

      return if query.exists?

      error = Cuprum::Collections::Errors::NotFound.new(
        collection_name:    collection_name,
        primary_key_name:   primary_key_name,
        primary_key_values: primary_key
      )
      failure(error)
    end

    def process(entity:)
      step { validate_entity(entity) }

      step { handle_missing_record(primary_key: entity[primary_key_name]) }

      entity.save

      entity
    end
  end
end
