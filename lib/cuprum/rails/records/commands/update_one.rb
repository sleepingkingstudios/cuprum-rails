# frozen_string_literal: true

require 'cuprum/rails/records/command'
require 'cuprum/rails/records/commands'

module Cuprum::Rails::Records::Commands
  # Command for updating an ActiveRecord record in the collection.
  class UpdateOne < Cuprum::Rails::Records::Command
    # @!method call(entity:)
    #   Updates the record in the collection.
    #
    #   If the collection does not already have a record with the same primary
    #   key, #call will fail and the collection will not be updated.
    #
    #   @param entity [ActiveRecord::Base] The collection record to persist.
    #
    #   @return [Cuprum::Result<ActiveRecord::Base>] the persisted record.
    validate :entity

    private

    def handle_missing_record(primary_key:)
      query = record_class.where(primary_key_name => primary_key)

      return if query.exists?

      failure(not_found_error(primary_key))
    end

    def process(entity:)
      step { handle_missing_record(primary_key: entity[primary_key_name]) }

      entity.save

      entity
    rescue ActiveRecord::StatementInvalid => exception
      failure(invalid_statement_error(exception.message))
    end
  end
end
