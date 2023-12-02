# frozen_string_literal: true

require 'cuprum/collections/errors/already_exists'

require 'cuprum/rails/command'
require 'cuprum/rails/commands'
require 'cuprum/rails/errors/invalid_statement'

module Cuprum::Rails::Commands
  # Command for inserting an ActiveRecord record into the collection.
  class InsertOne < Cuprum::Rails::Command
    # @!method call(entity:)
    #   Inserts the record into the collection.
    #
    #   If the collection already includes a record with the same primary key,
    #   #call will fail and the collection will not be updated.
    #
    #   @param entity [ActiveRecord::Base] The record to persist.
    #
    #   @return [Cuprum::Result<ActiveRecord::Base>] the persisted record.
    validate_parameters :call do
      keyword :entity, Object
    end

    private

    def already_exists_error(primary_key)
      Cuprum::Collections::Errors::AlreadyExists.new(
        attribute_name:  primary_key_name,
        attribute_value: primary_key,
        collection_name: collection_name,
        primary_key:     true
      )
    end

    def invalid_statement_error(message)
      Cuprum::Rails::Errors::InvalidStatement.new(message: message)
    end

    def process(entity:)
      step { validate_entity(entity) }

      entity.save

      entity
    rescue ActiveRecord::RecordNotUnique
      failure(already_exists_error(entity[primary_key_name]))
    rescue ActiveRecord::StatementInvalid => exception
      failure(invalid_statement_error(exception.message))
    end
  end
end
