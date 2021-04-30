# frozen_string_literal: true

require 'cuprum/collections/errors/not_found'

require 'cuprum/rails/command'
require 'cuprum/rails/commands'

module Cuprum::Rails::Commands
  # Command for destroying an ActiveRecord record by primary key.
  class DestroyOne < Cuprum::Rails::Command
    # @!method call(primary_key:)
    #   Finds and destroys the record with the given primary key.
    #
    #   The command will find the record with the given primary key and remove
    #   it from the collection. If the record is not found, the command will
    #   fail and return a NotFound error.
    #
    #   @param primary_key [Object] The primary key of the requested record.
    #
    #   @return [Cuprum::Result<Hash{String, Object}>] a result with the
    #     destroyed record.
    validate_parameters :call do
      keyword :primary_key, Object
    end

    private

    def process(primary_key:)
      step { validate_primary_key(primary_key) }

      entity = record_class.find(primary_key)

      entity.destroy
    rescue ActiveRecord::RecordNotFound
      error = Cuprum::Collections::Errors::NotFound.new(
        collection_name:    collection_name,
        primary_key_name:   primary_key_name,
        primary_key_values: [primary_key]
      )
      Cuprum::Result.new(error: error)
    end
  end
end
