# frozen_string_literal: true

require 'cuprum/rails/records/command'
require 'cuprum/rails/records/commands'

module Cuprum::Rails::Records::Commands
  # Command for inserting an ActiveRecord record into the collection.
  class InsertOne < Cuprum::Rails::Records::Command
    # @!method call(entity:)
    #   Inserts the record into the collection.
    #
    #   If the collection already includes a record with the same primary key,
    #   #call will fail and the collection will not be updated.
    #
    #   @param entity [ActiveRecord::Base] The record to persist.
    #
    #   @return [Cuprum::Result<ActiveRecord::Base>] the persisted record.
    validate :entity

    private

    def process(entity:)
      entity.save(validate: false)

      entity
    rescue ActiveRecord::RecordNotUnique
      failure(already_exists_error(entity[primary_key_name]))
    rescue ActiveRecord::StatementInvalid => exception
      failure(invalid_statement_error(exception.message))
    end
  end
end
