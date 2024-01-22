# frozen_string_literal: true

require 'cuprum/rails'

module Cuprum::Rails
  # Namespace for scope functionality, which filters query data.
  module Scopes
    autoload :AllScope,         'cuprum/rails/scopes/all_scope'
    autoload :Base,             'cuprum/rails/scopes/base'
    autoload :Builder,          'cuprum/rails/scopes/builder'
    autoload :ConjunctionScope, 'cuprum/rails/scopes/conjunction_scope'
    autoload :CriteriaScope,    'cuprum/rails/scopes/criteria_scope'
    autoload :DisjunctionScope, 'cuprum/rails/scopes/disjunction_scope'
    autoload :NoneScope,        'cuprum/rails/scopes/none_scope'
  end
end
