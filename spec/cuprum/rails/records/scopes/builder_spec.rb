# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/scopes/builder_contracts'
require 'cuprum/collections/scope'

require 'cuprum/rails/records/scopes/all_scope'
require 'cuprum/rails/records/scopes/builder'
require 'cuprum/rails/records/scopes/conjunction_scope'
require 'cuprum/rails/records/scopes/criteria_scope'
require 'cuprum/rails/records/scopes/disjunction_scope'
require 'cuprum/rails/records/scopes/none_scope'

RSpec.describe Cuprum::Rails::Records::Scopes::Builder do
  include Cuprum::Collections::RSpec::Contracts::Scopes::BuilderContracts

  subject(:builder) { described_class.instance }

  def build_scope
    Cuprum::Collections::Scope.new({ 'ok' => true })
  end

  include_contract 'should be a scope builder',
    all_class:         Cuprum::Rails::Records::Scopes::AllScope,
    conjunction_class: Cuprum::Rails::Records::Scopes::ConjunctionScope,
    criteria_class:    Cuprum::Rails::Records::Scopes::CriteriaScope,
    disjunction_class: Cuprum::Rails::Records::Scopes::DisjunctionScope,
    none_class:        Cuprum::Rails::Records::Scopes::NoneScope
end
