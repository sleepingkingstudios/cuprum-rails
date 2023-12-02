# frozen_string_literal: true

require 'cuprum/collections/errors/not_found'

require 'cuprum/rails/command'
require 'cuprum/rails/commands'
require 'cuprum/rails/errors/invalid_statement'

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

      failure(not_found_error(primary_key))
    end

    def invalid_statement_error(message)
      Cuprum::Rails::Errors::InvalidStatement.new(message: message)
    end

    def not_found_error(primary_key)
      Cuprum::Collections::Errors::NotFound.new(
        attribute_name:  primary_key_name,
        attribute_value: primary_key,
        collection_name: collection_name,
        primary_key:     true
      )
    end

    def process(entity:)
      step { validate_entity(entity) }

      step { handle_missing_record(primary_key: entity[primary_key_name]) }

      entity.save

      entity
    rescue ActiveRecord::StatementInvalid => exception
      failure(invalid_statement_error(exception.message))
    end
  end
end
