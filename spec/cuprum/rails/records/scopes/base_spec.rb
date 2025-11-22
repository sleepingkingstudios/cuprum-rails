# frozen_string_literal: true

require 'cuprum/collections/rspec/fixtures'

require 'cuprum/rails/records/scopes/base'
require 'cuprum/rails/rspec/deferred/scope_examples'

RSpec.describe Cuprum::Rails::Records::Scopes::Base do
  include Cuprum::Rails::RSpec::Deferred::ScopeExamples

  subject(:scope) { described_class.new }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_any_keywords
    end
  end

  include_deferred 'should implement the Records::Scope methods'

  describe '#build_relation' do
    let(:record_class) { Book }
    let(:relation) do
      scope.build_relation(record_class:)
    end
    let(:expected) do
      Book.all
    end

    it { expect(relation.to_a).to be == expected }

    wrap_deferred 'when the collection has many items' do
      it { expect(relation.to_a).to be == expected }
    end
  end

  describe '#call' do
    let(:native_query) { Book.all }

    it { expect(scope.call(native_query:)).to be native_query }
  end
end
