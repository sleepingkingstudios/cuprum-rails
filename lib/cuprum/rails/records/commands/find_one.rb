# frozen_string_literal: true

require 'cuprum/collections/commands/abstract_find_one'

require 'cuprum/rails/records/command'
require 'cuprum/rails/records/commands'

module Cuprum::Rails::Records::Commands
  # Command for finding one ActiveRecord record by primary key.
  class FindOne < Cuprum::Rails::Records::Command
    include Cuprum::Collections::Commands::AbstractFindOne

    # @!method call(primary_key:, envelope: false)
    #   Queries the collection for the record with the given primary key.
    #
    #   The command will find and return the entity with the given primary key.
    #   If the entity is not found, the command will fail and return a NotFound
    #   error.
    #
    #   When the :envelope option is true, the command wraps the record in a
    #   Hash, using the singular name of the collection as the key.
    #
    #   @param envelope [Boolean] If true, wraps the result value in a Hash.
    #   @param primary_key [Object] The primary key of the requested record.
    #
    #   @return [Cuprum::Result<Hash{String, Object}>] a result with the
    #     requested record.
    validate :envelope, :boolean, optional: true
    validate :primary_key

    private

    def process(primary_key:, envelope: false)
      super
    rescue ActiveRecord::StatementInvalid => exception
      failure(invalid_statement_error(exception.message))
    end
  end
end
