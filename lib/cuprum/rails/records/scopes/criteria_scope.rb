# frozen_string_literal: true

require 'cuprum/collections/queries'
require 'cuprum/collections/scopes/criteria'

require 'cuprum/rails/records/scopes'
require 'cuprum/rails/records/scopes/base'

module Cuprum::Rails::Records::Scopes
  # Scope for filtering on collection data based on criteria.
  class CriteriaScope < Cuprum::Rails::Records::Scopes::Base
    include Cuprum::Collections::Scopes::Criteria

    # Helper for generating SQL queries from criteria.
    class Builder # rubocop:disable Metrics/ClassLength
      Operators = Cuprum::Collections::Queries::Operators
      private_constant :Operators

      # @return [Cuprum::Rails::Records::Scopes::CriteriaScope::Builder] a
      #   singleton instance of the builder class.
      def self.instance
        @instance ||= new
      end

      # Generates a SQL query from a criteria array.
      #
      # @param criteria [Array<Array>] the scope criteria.
      # @param inverted [Boolean] if true, generates a SQL query for items that
      #   do not match the criteria.
      #
      # @return [String] the generated SQL query.
      def call(criteria:, inverted: false)
        criteria
          .map do |(attribute, operator, value)|
            build_statement(attribute, operator, value)
          end
          .join(inverted ? ' OR ' : ' AND ')
      end

      private

      def build_statement(attribute, operator, value) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
        case operator
        when Operators::EQUAL
          equal(attribute, value)
        when Operators::GREATER_THAN
          greater_than(attribute, value)
        when Operators::GREATER_THAN_OR_EQUAL_TO
          greater_than_or_equal_to(attribute, value)
        when Operators::LESS_THAN
          less_than(attribute, value)
        when Operators::LESS_THAN_OR_EQUAL_TO
          less_than_or_equal_to(attribute, value)
        when Operators::NOT_EQUAL
          not_equal(attribute, value)
        when Operators::NOT_ONE_OF
          not_one_of(attribute, value)
        when Operators::ONE_OF
          one_of(attribute, value)
        else
          raise invalid_operator_error(operator)
        end
      end

      def equal(attribute, value)
        return sanitize(':attribute IS NULL', attribute:) if value.nil?

        sanitize(
          ':attribute = :value',
          attribute:,
          value:
        )
      end

      def greater_than(attribute, value)
        sanitize(
          ':attribute > :value',
          attribute:,
          value:
        )
      end

      def greater_than_or_equal_to(attribute, value)
        sanitize(
          ':attribute >= :value',
          attribute:,
          value:
        )
      end

      def invalid_operator_error(operator)
        error_class =
          Cuprum::Collections::Queries::UnknownOperatorException
        message     = %(unknown operator "#{operator}")

        error_class.new(message, operator)
      end

      def less_than(attribute, value)
        sanitize(
          ':attribute < :value',
          attribute:,
          value:
        )
      end

      def less_than_or_equal_to(attribute, value)
        sanitize(
          ':attribute <= :value',
          attribute:,
          value:
        )
      end

      def not_equal(attribute, value)
        return sanitize(':attribute IS NOT NULL', attribute:) if value.nil?

        sanitize(
          '(:attribute != :value OR :attribute IS NULL)',
          attribute:,
          value:
        )
      end

      def not_one_of(attribute, value)
        sanitize(
          '(:attribute NOT IN (:value) OR :attribute IS NULL)',
          attribute:,
          value:
        )
      end

      def one_of(attribute, value)
        sanitize(':attribute IN (:value)', attribute:, value:)
      end

      def sanitize(template, attribute:, **conditions)
        attribute =
          ActiveRecord::Base
            .sanitize_sql([':attribute', { attribute: }])
            .then { |str| str[1...-1] }
        template  = template.gsub(':attribute', attribute)

        ActiveRecord::Base.sanitize_sql([template, conditions])
      end
    end

    private

    def process(native_query:)
      return inverted? ? native_query.none : native_query if empty?

      sql = Builder.instance.call(criteria:, inverted: inverted?)

      native_query.where(sql)
    end
  end
end
