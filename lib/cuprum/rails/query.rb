# frozen_string_literal: true

require 'cuprum/collections/query'

require 'cuprum/rails'

module Cuprum::Rails
  # Interface for performing query operations on a Rails collection.
  class Query < Cuprum::Collections::Query
    extend  Forwardable
    include Enumerable

    def_delegators :scoped_query,
      :each,
      :exists?,
      :to_a

    # @param record_class [Class] The class of the collection items. Must be a
    #   subclass of ActiveRecord::Base.
    # @param native_query [ActiveRecord::Relation] A relation used to scope the
    #   query.
    # @param scope [Cuprum::Rails::Scopes::Base] the base scope for the query.
    #   Defaults to nil.
    def initialize(record_class, native_query: nil, scope: nil)
      super(scope: scope)

      @native_query = native_query || record_class.all
      @scoped_query = self.scope.call(native_query: @native_query)
      @record_class = record_class
      @order        = { record_class.primary_key => :asc }
    end

    # @return [Class] the class of the collection items.
    attr_reader :record_class

    protected

    def reset!
      @scoped_query&.reset

      self
    end

    def with_limit(count)
      @scoped_query = nil

      super
    end

    def with_native_query(native_query)
      @native_query = native_query
      @scoped_query = nil

      self
    end

    def with_offset(count)
      @scoped_query = nil

      super
    end

    def with_order(order)
      @scoped_query = nil

      super
    end

    def with_scope(scope)
      @scoped_query = nil

      super
    end

    private

    attr_reader :native_query

    def default_scope
      Cuprum::Rails::Scopes::AllScope.instance
    end

    def scoped_query
      return @scoped_query if @scoped_query

      @scoped_query = scope.call(native_query: native_query)
      @scoped_query = @scoped_query.limit(@limit)   if @limit
      @scoped_query = @scoped_query.offset(@offset) if @offset
      @scoped_query = @scoped_query.reorder(@order) if @order

      @scoped_query
    end
  end
end
