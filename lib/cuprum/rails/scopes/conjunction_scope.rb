# frozen_string_literal: true

require 'cuprum/collections/scopes/conjunction'

require 'cuprum/rails/scopes'
require 'cuprum/rails/scopes/base'

module Cuprum::Rails::Scopes
  # Scope for filtering data matching all of the given scopes.
  class ConjunctionScope < Cuprum::Rails::Scopes::Base
    include Cuprum::Collections::Scopes::Conjunction

    private

    def process(native_query:)
      scopes.reduce(super) do |query, scope|
        query.and(scope.build_relation(record_class: native_query.klass))
      end
    end
  end
end
