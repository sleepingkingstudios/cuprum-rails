# frozen_string_literal: true

require 'cuprum/collections/scopes/disjunction'

require 'cuprum/rails/records/scopes'
require 'cuprum/rails/records/scopes/base'

module Cuprum::Rails::Records::Scopes
  # Scope for filtering data matching any of the given scopes.
  class DisjunctionScope < Cuprum::Rails::Records::Scopes::Base
    include Cuprum::Collections::Scopes::Disjunction

    private

    def process(native_query:)
      return native_query.none if empty?

      scopes
        .map { |scope| scope.build_relation(record_class: native_query.klass) }
        .reduce { |query, relation| query.or(relation) }
    end
  end
end
