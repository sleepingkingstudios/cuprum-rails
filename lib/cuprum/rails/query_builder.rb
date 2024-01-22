# frozen_string_literal: true

require 'cuprum/rails'

module Cuprum::Rails
  # Applies filter operations for a Rails collection query.
  class QueryBuilder
    # @param base_query [Cuprum::Rails::Query] The query to build.
    def initialize(base_query)
      super

      @native_query = base_query.send(:native_query)
    end

    private

    attr_reader :native_query

    def build_native_query(criteria)
      native_query.where(
        criteria
          .map do |(attribute, operator, value)|
            send(operator, attribute, value)
          end
          .join(' AND ')
      )
    end

    def build_query(criteria)
      super.send(:with_native_query, build_native_query(criteria))
    end

    def equal(attribute, value)
      return sanitize("#{attribute} IS NULL") if value.nil?

      sanitize("#{attribute} = :value", value: value)
    end

    def greater_than(attribute, value)
      sanitize("#{attribute} > :value", value: value)
    end

    def greater_than_or_equal_to(attribute, value)
      sanitize("#{attribute} >= :value", value: value)
    end

    def less_than(attribute, value)
      sanitize("#{attribute} < :value", value: value)
    end

    def less_than_or_equal_to(attribute, value)
      sanitize("#{attribute} <= :value", value: value)
    end

    def not_equal(attribute, value)
      return sanitize("#{attribute} IS NOT NULL") if value.nil?

      sanitize("(#{attribute} != :value OR #{attribute} IS NULL)", value: value)
    end

    def not_one_of(attribute, value)
      sanitize(
        "(#{attribute} NOT IN (:value) OR #{attribute} IS NULL)",
        value: value
      )
    end

    def one_of(attribute, value)
      sanitize("#{attribute} IN (:value)", value: value)
    end

    def sanitize(*conditions)
      ActiveRecord::Base.sanitize_sql_for_conditions(conditions)
    end
  end
end
