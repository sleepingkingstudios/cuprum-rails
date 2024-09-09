# frozen_string_literal: true

require 'cuprum/rails/records/command'
require 'cuprum/rails/records/commands'

module Cuprum::Rails::Records::Commands
  # Command for destroying an ActiveRecord record by primary key.
  class DestroyOne < Cuprum::Rails::Records::Command
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
    validate :primary_key

    private

    def process(primary_key:)
      step { validate_primary_key(primary_key) }

      entity = record_class.find(primary_key)

      entity.destroy
    rescue ActiveRecord::RecordNotFound
      Cuprum::Result.new(error: not_found_error(primary_key))
    end
  end
end
