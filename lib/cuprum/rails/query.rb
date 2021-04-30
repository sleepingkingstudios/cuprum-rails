# frozen_string_literal: true

require 'cuprum/collections/query'

require 'cuprum/rails'
require 'cuprum/rails/query_builder'

module Cuprum::Rails
  # @todo Document Query.
  class Query < Cuprum::Collections::Query
    extend  Forwardable
    include Enumerable

    def_delegators :@native_query,
      :each,
      :exists?,
      :to_a

    # @todo Document #initialize.
    def initialize(record_class, native_query: nil)
      super()

      @native_query = native_query || record_class.all
      @record_class = record_class
      @limit        = nil
      @offset       = nil
      @order        = {}
    end

    # @todo Document #record_class.
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
      @native_query = @native_query.order(order)

      super
    end

    private

    attr_reader :native_query
  end
end
