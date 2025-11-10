# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/collection_examples'
require 'cuprum/collections/rspec/fixtures'

require 'cuprum/rails/records/collection'
require 'cuprum/rails/records/commands'

require 'support/book'
require 'support/tome'

RSpec.describe Cuprum::Rails::Records::Collection do
  include Cuprum::Collections::RSpec::Deferred::CollectionExamples

  subject(:collection) { described_class.new(**constructor_options) }

  shared_context 'when the collection has many items' do
    let(:data)  { Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES }
    let(:items) { data.map { |attributes| Book.new(attributes) } }

    before(:example) { items.each(&:save!) }
  end

  let(:name)                { 'books' }
  let(:entity_class)        { Book }
  let(:constructor_options) { { name: } }
  let(:query_class)         { Cuprum::Rails::Records::Query }
  let(:query_options)       { { record_class: entity_class } }
  let(:default_order)       { { entity_class.primary_key => :asc } }

  example_class 'Grimoire',         Book
  example_class 'Spec::ScopedBook', Book

  include_deferred 'should be a Collection',
    commands_namespace: 'Cuprum::Rails::Records::Commands',
    default_scope:      Cuprum::Rails::Records::Scopes::AllScope

  describe '#primary_key_name' do
    context 'when the record class defines a custom primary key' do
      let(:name)         { 'tomes' }
      let(:entity_class) { Tome }

      it { expect(collection.primary_key_name).to be == 'uuid' }

      context 'when initialized with primary_key_name: a String' do
        let(:primary_key_name) { 'id' }
        let(:constructor_options) do
          super().merge(primary_key_name:)
        end

        it { expect(collection.primary_key_name).to be == primary_key_name }
      end
    end
  end

  describe '#primary_key_type' do
    context 'when the record class defines a custom primary key' do
      let(:name)         { 'tomes' }
      let(:entity_class) { Tome }

      it { expect(collection.primary_key_type).to be String }

      context 'when initialized with primary_key_name: a Class' do
        let(:primary_key_type) { Integer }
        let(:constructor_options) do
          super().merge(primary_key_type:)
        end

        it { expect(collection.primary_key_type).to be primary_key_type }
      end
    end
  end
end
