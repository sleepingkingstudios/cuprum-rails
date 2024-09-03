# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/scopes/logical_contracts'

require 'cuprum/rails/rspec/contracts/scope_contracts'
require 'cuprum/rails/scopes/criteria_scope'
require 'cuprum/rails/scopes/disjunction_scope'

RSpec.describe Cuprum::Rails::Scopes::DisjunctionScope do
  include Cuprum::Collections::RSpec::Contracts::Scopes::LogicalContracts
  include Cuprum::Rails::RSpec::Contracts::ScopeContracts

  subject(:scope) { described_class.new(scopes:) }

  let(:scopes)       { [] }
  let(:native_query) { Book.all }
  let(:data)         { [] }

  def build_scope(filters = nil, &block)
    scope_class = Cuprum::Rails::Scopes::CriteriaScope

    if block_given?
      scope_class.build(&block)
    else
      scope_class.build(filters)
    end
  end

  def filtered_data
    scope
      .call(native_query:)
      .map do |record|
        record
          .attributes
          .merge('published_at' => record.published_at.strftime('%Y-%m-%d'))
      end
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:scopes)
        .and_any_keywords
    end
  end

  include_contract 'should be a disjunction scope'

  include_contract 'should be a rails scope'

  describe '#build_relation' do
    let(:record_class) { Book }

    def filtered_data
      scope
        .build_relation(record_class:)
        .map do |record|
          record
            .attributes
            .merge('published_at' => record.published_at.strftime('%Y-%m-%d'))
        end
    end

    include_contract 'should filter data by logical or'
  end
end
