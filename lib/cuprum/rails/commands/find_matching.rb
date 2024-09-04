# frozen_string_literal: true

require 'cuprum/collections/commands/abstract_find_matching'
require 'cuprum/collections/constraints/ordering'

require 'cuprum/rails/command'
require 'cuprum/rails/commands'
require 'cuprum/rails/records/query'

module Cuprum::Rails::Commands
  # Command for querying filtered, ordered data from a Rails collection.
  class FindMatching < Cuprum::Rails::Command
    include Cuprum::Collections::Commands::AbstractFindMatching

    # @!method call(envelope: false, limit: nil, offset: nil, order: nil, where: nil, &block)
    #   Queries the collection for records matching the given conditions.
    #
    #   @param envelope [Boolean] If true, wraps the result value in a Hash.
    #   @param limit [Integer] The maximum number of results to return.
    #   @param offset [Integer] The initial ordered items to skip.
    #   @param order [Array<String, Symbol>, Hash<{String, Symbol => Symbol}>]
    #     The sort order of the returned items. Should be either an array of
    #     attribute names or a hash of attribute names and directions.
    #   @param where [Object] Additional filters for selecting data. The command
    #     will only return data matching these filters.
    #   @yield The given block is passed to a QueryBuilder, which converts the
    #     block to query criteria and generates a new query using those
    #     criteria.
    #   @yieldreturn [Hash] The filters to apply to the query. The hash keys
    #     should be the names of attributes or columns, and the corresponding
    #     values should be either the literal value for that attribute or a
    #     method call for a valid operation defined for the query.
    #
    #   @example Querying all records in the collection.
    #     command = FindMatching.new(collection_name: 'books', data: books)
    #     command.call
    #     #=> an enumerable iterating all records in the collection
    #
    #   @example Querying all records matching some critera:
    #     command.call { { author: 'Nnedi Okorafor' } }
    #     #=> an enumerable iterating all records in the collection whose author
    #         is 'Nnedi Okorafor'
    #
    #   @example Ordering query results
    #     command.call(order: :title) { { author: 'Nnedi Okorafor' } }
    #     #=> an enumerable iterating all records in the collection whose author
    #     #   is 'Nnedi Okorafor', sorted by :title in ascending order
    #
    #   @example Advanced filtering
    #     command.call do
    #       {
    #         category: eq('Science Fiction and Fantasy'),
    #         author:   ne('J.R.R. Tolkien')
    #       }
    #     end
    #     #=> an enumerable iterating all records in the collection whose
    #     #   category is 'Science Fiction and Fantasy', and whose author is not
    #     #   'J.R.R. Tolkien'.
    #
    #   @example Advanced ordering
    #     order = { author: :asc, genre: :desc }
    #     command.call(order: order) { { author: 'Nnedi Okorafor' } }
    #     #=> an enumerable iterating all records in the collection whose author
    #     #   is 'Nnedi Okorafor', sorted first by :author in ascending order
    #     #   and within the same author by genre in descending order
    #
    #   @example Filtering, ordering, and subsets
    #     command.call(offset: 50, limit: 10, order: :author) do
    #       { category: 'Science Fiction and Fantasy' }
    #     end
    #     #=> an enumerable iterating the 51st through 60th records in the
    #     #   collection whose category is 'Science Fiction and Fantasy', sorted
    #     #   by :author in ascending order.
    #
    #   @example Wrapping the result in an envelope
    #     command =
    #       Filter.new(collection_name: 'books', data: books)
    #     command.call(envelope: true)
    #     #=> {
    #       'books' => [] # an array containing the matching records
    #     }
    #
    #   @overload call(limit: nil, offset: nil, order: nil, &block)
    #     When the :envelope option is false (default), the command returns an
    #     Enumerator which can be iterated to return the matching records.
    #
    #     @return [Cuprum::Result<Enumerator>] the matching records in the
    #       specified order as an Enumerator.
    #
    #   @overload call(limit: nil, offset: nil, order: nil, &block)
    #     When the :envelope option is true, the command immediately evaluates
    #     the query and wraps the resulting array in a Hash, using the name of
    #     the collection as the key.
    #
    #     @return [Cuprum::Result<Hash{String, Array<ActiveRecord::Base>}>] a
    #       hash with the collection name as key and the matching records as
    #       value.
    validate_parameters :call do
      keyword :envelope,
        Stannum::Constraints::Boolean.new,
        default: true
      keyword :limit, Integer, optional: true
      keyword :offset, Integer, optional: true
      keyword :order,
        Cuprum::Collections::Constraints::Ordering.new,
        optional: true
      keyword :where, Object, optional: true
    end
  end
end
