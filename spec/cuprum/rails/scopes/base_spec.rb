# frozen_string_literal: true

require 'cuprum/collections/rspec/fixtures'

require 'cuprum/rails/rspec/contracts/scope_contracts'
require 'cuprum/rails/scopes/base'

RSpec.describe Cuprum::Rails::Scopes::Base do
  include Cuprum::Rails::RSpec::Contracts::ScopeContracts

  subject(:scope) { described_class.new }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_any_keywords
    end
  end

  include_contract 'should be a rails scope'

  describe '#build_relation' do
    let(:record_class) { Book }
    let(:relation) do
      scope.build_relation(record_class:)
    end
    let(:expected) do
      Book.all
    end

    it { expect(relation.to_a).to be == expected }

    wrap_context 'when the collection has many items' do
      it { expect(relation.to_a).to be == expected }
    end
  end

  describe '#call' do
    let(:native_query) { Book.all }

    it { expect(scope.call(native_query:)).to be native_query }
  end
end
