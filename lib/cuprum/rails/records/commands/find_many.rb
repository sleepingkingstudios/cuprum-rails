# frozen_string_literal: true

require 'cuprum/collections/commands/abstract_find_many'

require 'cuprum/rails/records/command'
require 'cuprum/rails/records/commands'

module Cuprum::Rails::Records::Commands
  # Command for finding multiple ActiveRecord records by primary key.
  class FindMany < Cuprum::Rails::Records::Command
    include Cuprum::Collections::Commands::AbstractFindMany

    # @!method call(primary_keys:, allow_partial: false, envelope: false)
    #   Queries the collection for the records with the given primary keys.
    #
    #   The command will find and return the entities with the given primary
    #   keys. If any of the records are not found, the command will fail and
    #   return a NotFound error. If the :allow_partial option is set, the
    #   command will return a partial result unless none of the requested
    #   records are found.
    #
    #   When the :envelope option is true, the command wraps the records in a
    #   Hash, using the name of the collection as the key.
    #
    #   @param allow_partial [Boolean] If true, passes if any of the records are
    #     found.
    #   @param envelope [Boolean] If true, wraps the result value in a Hash.
    #   @param primary_keys [Array] The primary keys of the requested records.
    #
    #   @return [Cuprum::Result<Array<ActiveRecord>>] a result with the
    #     requested records.
    validate :allow_partial, :boolean, optional: true
    validate :envelope,      :boolean, optional: true
    validate :primary_keys

    private

    def process(primary_keys:, allow_partial: false, envelope: false)
      super
    rescue ActiveRecord::StatementInvalid => exception
      failure(invalid_statement_error(exception.message))
    end
  end
end
