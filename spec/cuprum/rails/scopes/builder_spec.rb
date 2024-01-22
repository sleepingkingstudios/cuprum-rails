# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/scopes/builder_contracts'
require 'cuprum/collections/scope'

require 'cuprum/rails/scopes/all_scope'
require 'cuprum/rails/scopes/builder'
require 'cuprum/rails/scopes/conjunction_scope'
require 'cuprum/rails/scopes/criteria_scope'
require 'cuprum/rails/scopes/disjunction_scope'
require 'cuprum/rails/scopes/none_scope'

RSpec.describe Cuprum::Rails::Scopes::Builder do
  include Cuprum::Collections::RSpec::Contracts::Scopes::BuilderContracts

  subject(:builder) { described_class.instance }

  def build_scope
    Cuprum::Collections::Scope.new({ 'ok' => true })
  end

  include_contract 'should be a scope builder',
    all_class:         Cuprum::Rails::Scopes::AllScope,
    conjunction_class: Cuprum::Rails::Scopes::ConjunctionScope,
    criteria_class:    Cuprum::Rails::Scopes::CriteriaScope,
    disjunction_class: Cuprum::Rails::Scopes::DisjunctionScope,
    none_class:        Cuprum::Rails::Scopes::NoneScope
end
