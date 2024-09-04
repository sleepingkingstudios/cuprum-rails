# frozen_string_literal: true

require 'cuprum/rails/records/scopes'

module Cuprum::Rails::Records::Scopes
  # Builder for generating Rails collection scopes.
  class Builder
    include Cuprum::Collections::Scopes::Building

    private

    def all_scope_class
      Cuprum::Rails::Records::Scopes::AllScope
    end

    def conjunction_scope_class
      Cuprum::Rails::Records::Scopes::ConjunctionScope
    end

    def criteria_scope_class
      Cuprum::Rails::Records::Scopes::CriteriaScope
    end

    def disjunction_scope_class
      Cuprum::Rails::Records::Scopes::DisjunctionScope
    end

    def none_scope_class
      Cuprum::Rails::Records::Scopes::NoneScope
    end
  end
end

require 'cuprum/rails/records/scopes/all_scope'
require 'cuprum/rails/records/scopes/conjunction_scope'
require 'cuprum/rails/records/scopes/criteria_scope'
require 'cuprum/rails/records/scopes/disjunction_scope'
require 'cuprum/rails/records/scopes/none_scope'
