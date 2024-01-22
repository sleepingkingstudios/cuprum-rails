# frozen_string_literal: true

require 'cuprum/collections/query'

require 'cuprum/rails'

module Cuprum::Rails
  # Interface for performing query operations on a Rails collection.
  class Query < Cuprum::Collections::Query
    extend  Forwardable
    include Enumerable

    def_delegators :@native_query,
      :each,
      :exists?,
      :to_a

    # @param record_class [Class] The class of the collection items. Must be a
    #   subclass of ActiveRecord::Base.
    # @param native_query [ActiveRecord::Relation] A relation used to scope the
    #   query.
    def initialize(record_class, native_query: nil)
      super()

      default_order = { record_class.primary_key => :asc }
      @native_query = native_query || record_class.order(default_order)
      @record_class = record_class
      @limit        = nil
      @offset       = nil
      @order        = default_order
    end

    # @return [Class] the class of the collection items.
    attr_reader :record_class

    protected

    def query_builder
      Cuprum::Rails::QueryBuilder.new(self)
    end

    def reset!
      @native_query.reset

      self
    end

    def with_limit(count)
      @native_query = @native_query.limit(count)

      super
    end

    def with_native_query(native_query)
      @native_query = native_query

      self
    end

    def with_offset(count)
      @native_query = @native_query.offset(count)

      super
    end

    def with_order(order)
      @native_query = @native_query.reorder(order)

      super
    end

    private

    attr_reader :native_query
  end
end
