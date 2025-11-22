# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/scopes/builder_examples'
require 'cuprum/collections/scope'

require 'cuprum/rails/records/scopes/all_scope'
require 'cuprum/rails/records/scopes/builder'
require 'cuprum/rails/records/scopes/conjunction_scope'
require 'cuprum/rails/records/scopes/criteria_scope'
require 'cuprum/rails/records/scopes/disjunction_scope'
require 'cuprum/rails/records/scopes/none_scope'

RSpec.describe Cuprum::Rails::Records::Scopes::Builder do
  include Cuprum::Collections::RSpec::Deferred::Scopes::BuilderExamples

  subject(:builder) { described_class.instance }

  def build_scope
    Cuprum::Collections::Scope.new({ 'ok' => true })
  end

  include_deferred 'should build collection Scopes',
    namespace: Cuprum::Rails::Records::Scopes
end
