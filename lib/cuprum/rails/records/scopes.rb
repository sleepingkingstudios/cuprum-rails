# frozen_string_literal: true

require 'cuprum/rails/records'

module Cuprum::Rails::Records
  # Namespace for scope functionality, which filters query data.
  module Scopes
    autoload :AllScope,         'cuprum/rails/records/scopes/all_scope'
    autoload :Base,             'cuprum/rails/records/scopes/base'
    autoload :Builder,          'cuprum/rails/records/scopes/builder'
    autoload :ConjunctionScope, 'cuprum/rails/records/scopes/conjunction_scope'
    autoload :CriteriaScope,    'cuprum/rails/records/scopes/criteria_scope'
    autoload :DisjunctionScope, 'cuprum/rails/records/scopes/disjunction_scope'
    autoload :NoneScope,        'cuprum/rails/records/scopes/none_scope'
  end
end
