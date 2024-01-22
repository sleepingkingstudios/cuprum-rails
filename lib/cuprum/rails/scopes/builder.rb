# frozen_string_literal: true

require 'cuprum/rails/scopes'

module Cuprum::Rails::Scopes
  # Builder for generating Rails collection scopes.
  class Builder
    include Cuprum::Collections::Scopes::Building

    private

    def all_scope_class
      Cuprum::Rails::Scopes::AllScope
    end

    def conjunction_scope_class
      Cuprum::Rails::Scopes::ConjunctionScope
    end

    def criteria_scope_class
      Cuprum::Rails::Scopes::CriteriaScope
    end

    def disjunction_scope_class
      Cuprum::Rails::Scopes::DisjunctionScope
    end

    def none_scope_class
      Cuprum::Rails::Scopes::NoneScope
    end
  end
end

require 'cuprum/rails/scopes/all_scope'
require 'cuprum/rails/scopes/conjunction_scope'
require 'cuprum/rails/scopes/criteria_scope'
require 'cuprum/rails/scopes/disjunction_scope'
require 'cuprum/rails/scopes/none_scope'
