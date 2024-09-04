# frozen_string_literal: true

require 'cuprum/collections/scopes/conjunction'

require 'cuprum/rails/records/scopes'
require 'cuprum/rails/records/scopes/base'

module Cuprum::Rails::Records::Scopes
  # Scope for filtering data matching all of the given scopes.
  class ConjunctionScope < Cuprum::Rails::Records::Scopes::Base
    include Cuprum::Collections::Scopes::Conjunction

    private

    def process(native_query:)
      scopes.reduce(super) do |query, scope|
        query.and(scope.build_relation(record_class: native_query.klass))
      end
    end
  end
end
