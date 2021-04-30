# frozen_string_literal: true

require 'cuprum/collections/errors/already_exists'

require 'cuprum/rails/command'
require 'cuprum/rails/commands'

module Cuprum::Rails::Commands
  # Command for inserting an ActiveRecord record into the collection.
  class InsertOne < Cuprum::Rails::Command
    # @!method call(entity:)
    #   Inserts the record into the collection.
    #
    #   If the collection already includes a record with the same primary key,
    #   #call will fail and the collection will not be updated.
    #
    #   @param record [ActiveRecord::Base] The record to persist.
    #
    #   @return [Cuprum::Result<ActiveRecord::Base>] the persisted record.
    validate_parameters :call do
      keyword :entity, Object
    end

    private

    def process(entity:)
      step { validate_entity(entity) }

      entity.save

      entity
    rescue ActiveRecord::RecordNotUnique
      error = Cuprum::Collections::Errors::AlreadyExists.new(
        collection_name:    collection_name,
        primary_key_name:   primary_key_name,
        primary_key_values: entity[primary_key_name]
      )
      failure(error)
    end
  end
end
