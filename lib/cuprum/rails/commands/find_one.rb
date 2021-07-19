# frozen_string_literal: true

require 'stannum/constraints/boolean'

require 'cuprum/collections/commands/abstract_find_one'

require 'cuprum/rails/command'
require 'cuprum/rails/commands'

module Cuprum::Rails::Commands
  # Command for finding one ActiveRecord record by primary key.
  class FindOne < Cuprum::Rails::Command
    include Cuprum::Collections::Commands::AbstractFindOne

    # @!method call(primary_key:, envelope: false, scope: nil)
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
    #   @param scope [Cuprum::Collections::Basic::Query, nil] Optional scope for
    #     the query. The record must match the scope as well as the primary key.
    #
    #   @return [Cuprum::Result<Hash{String, Object}>] a result with the
    #     requested record.
    validate_parameters :call do
      keyword :envelope,    Stannum::Constraints::Boolean.new, default: true
      keyword :primary_key, Object
      keyword :scope,       Cuprum::Rails::Query, optional: true
    end

    private

    def build_query
      Cuprum::Rails::Query.new(record_class)
    end

    def process(primary_key:, envelope: false, scope: nil)
      step { validate_primary_key(primary_key) }

      super
    end
  end
end
