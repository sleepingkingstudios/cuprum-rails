# frozen_string_literal: true

require 'cuprum/collections/rspec/collection_contract'
require 'cuprum/collections/rspec/fixtures'

require 'cuprum/rails/collection'
require 'cuprum/rails/commands'

require 'support/book'
require 'support/tome'

RSpec.describe Cuprum::Rails::Collection do
  subject(:collection) { described_class.new(**constructor_options) }

  shared_context 'when the collection has many items' do
    let(:data)  { Cuprum::Collections::RSpec::BOOKS_FIXTURES }
    let(:items) { data.map { |attributes| Book.new(attributes) } }

    before(:each) { items.each(&:save!) }
  end

  let(:collection_name)     { 'books' }
  let(:entity_class)        { Book }
  let(:constructor_options) { { collection_name: collection_name } }
  let(:query_class)         { Cuprum::Rails::Query }
  let(:query_options)       { { record_class: entity_class } }
  let(:default_order)       { { entity_class.primary_key => :asc } }

  example_class 'Grimoire',         Book
  example_class 'Spec::ScopedBook', Book

  include_contract Cuprum::Collections::RSpec::CollectionContract,
    commands_namespace: 'Cuprum::Rails::Commands'

  describe '#==' do
    let(:other_options) do
      constructor_options.merge(collection_name: collection_name)
    end
    let(:other_collection) { described_class.new(**other_options) }

    describe 'with nil' do
      it { expect(collection == nil).to be false } # rubocop:disable Style/NilComparison
    end

    describe 'with an object' do
      it { expect(collection == Object.new.freeze).to be false }
    end

    describe 'with another collection' do
      it { expect(collection == other_collection).to be true }

      context 'with a non-matching collection name' do
        let(:other_options) { super().merge(collection_name: 'tomes') }

        it { expect(collection == other_collection).to be false }
      end

      context 'with a non-matching member name' do
        let(:other_options) { super().merge(member_name: 'grimoire') }

        it { expect(collection == other_collection).to be false }
      end

      context 'with a non-matching record class' do
        let(:other_options) { super().merge(entity_class: Tome) }

        it { expect(collection == other_collection).to be false }
      end

      context 'with non-matching options' do
        let(:other_options) { super().merge(key: 'other value') }

        it { expect(collection == other_collection).to be false }
      end
    end

    context 'when initialized with collection_name: string' do
      let(:collection_name) { 'tomes' }
      let(:constructor_options) do
        super().merge(collection_name: collection_name)
      end

      describe 'with another collection' do
        context 'with a non-matching collection name' do
          let(:other_options) { super().merge(collection_name: 'books') }

          it { expect(collection == other_collection).to be false }
        end

        context 'with a matching collection name' do
          let(:other_options) { super().merge(collection_name: 'tomes') }

          it { expect(collection == other_collection).to be true }
        end
      end
    end

    context 'when initialized with member_name: string' do
      let(:member_name)         { 'tome' }
      let(:constructor_options) { super().merge(member_name: member_name) }

      describe 'with another collection' do
        context 'with a non-matching member name' do
          let(:other_options) { super().merge(member_name: 'grimoire') }

          it { expect(collection == other_collection).to be false }
        end

        context 'with a matching member name' do
          let(:other_options) { super().merge(member_name: 'tome') }

          it { expect(collection == other_collection).to be true }
        end
      end
    end

    context 'when initialized with options' do
      let(:constructor_options) { super().merge({ key: 'value' }) }
      let(:expected_options)    { super().merge({ key: 'value' }) }

      describe 'with another collection' do
        context 'with non-matching options' do
          let(:other_options) { super().merge(key: 'other value') }

          it { expect(collection == other_collection).to be false }
        end

        context 'with matching options' do
          let(:other_options) { super().merge(key: 'value') }

          it { expect(collection == other_collection).to be true }
        end
      end
    end
  end

  describe '#entity_class' do
    it 'should alias the method' do
      expect(collection)
        .to have_aliased_method(:entity_class)
        .as(:record_class)
    end

    context 'when initialized with record_class: a Class' do
      let(:record_class) { Book }
      let(:constructor_options) do
        super()
          .tap { |hsh| hsh.delete(:collection_name) }
          .merge(record_class: record_class)
      end

      it { expect(collection.entity_class).to be Book }
    end

    context 'when initialized with record_class: a String' do
      let(:record_class) { 'Book' }
      let(:constructor_options) do
        super()
          .tap { |hsh| hsh.delete(:collection_name) }
          .merge(record_class: record_class)
      end

      it { expect(collection.entity_class).to be Book }
    end
  end
end
