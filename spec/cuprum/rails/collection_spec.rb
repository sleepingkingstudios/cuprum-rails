# frozen_string_literal: true

require 'cuprum/collections/rspec/collection_contract'

require 'cuprum/rails/collection'
require 'cuprum/rails/commands'

require 'support/book'
require 'support/tome'

RSpec.describe Cuprum::Rails::Collection do
  subject(:collection) do
    described_class.new(
      record_class: record_class,
      **constructor_options
    )
  end

  let(:record_class)        { Book }
  let(:constructor_options) { {} }
  let(:query_class)         { Cuprum::Rails::Query }
  let(:query_options)       { { record_class: record_class } }
  let(:default_order)       { { record_class.primary_key => :asc } }

  def self.command_options
    %i[
      collection_name
      member_name
      options
      record_class
    ].freeze
  end

  def self.commands_namespace
    Cuprum::Rails::Commands
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:record_class)
        .and_any_keywords
    end
  end

  include_contract Cuprum::Collections::RSpec::CollectionContract

  describe '#==' do
    let(:other_options) do
      constructor_options.merge(record_class: record_class)
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
        let(:other_options) { super().merge(record_class: Tome) }

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
          let(:other_options) { super().merge(collection_name: 'booms') }

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

  describe '#collection_name' do
    let(:expected) { record_class.name.split('::').last.underscore.pluralize }

    include_examples 'should define reader',
      :collection_name,
      -> { be == expected }

    context 'when initialized with collection_name: string' do
      let(:collection_name) { 'tomes' }
      let(:constructor_options) do
        super().merge(collection_name: collection_name)
      end

      it { expect(collection.collection_name).to be == collection_name }
    end

    context 'when initialized with collection_name: symbol' do
      let(:collection_name) { :tomes }
      let(:constructor_options) do
        super().merge(collection_name: collection_name)
      end

      it { expect(collection.collection_name).to be == collection_name.to_s }
    end

    context 'when initialized with resource_class: a scoped Class' do
      let(:record_class) { Spec::ScopedBook }

      example_class 'Spec::ScopedBook', Book

      it { expect(collection.collection_name).to be == expected }
    end
  end

  describe '#member_name' do
    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    include_examples 'should have reader',
      :member_name,
      -> { record_class.name.underscore }

    context 'when initialized with collection_name: value' do
      let(:collection_name) { :books }

      it 'should return the singular collection name' do
        expect(collection.member_name)
          .to be == tools.str.singularize(collection_name.to_s)
      end
    end

    context 'when initialized with member_name: string' do
      let(:member_name)         { 'tome' }
      let(:constructor_options) { super().merge(member_name: member_name) }

      it 'should return the singular collection name' do
        expect(collection.member_name).to be member_name
      end
    end

    context 'when initialized with member_name: symbol' do
      let(:member_name)         { :tome }
      let(:constructor_options) { super().merge(member_name: member_name) }

      it 'should return the singular collection name' do
        expect(collection.member_name).to be == member_name.to_s
      end
    end
  end

  describe '#options' do
    let(:expected_options) do
      defined?(super()) ? super() : constructor_options
    end

    include_examples 'should define reader',
      :options,
      -> { be == expected_options }

    context 'when initialized with options' do
      let(:constructor_options) { super().merge({ key: 'value' }) }
      let(:expected_options)    { super().merge({ key: 'value' }) }

      it { expect(collection.options).to be == expected_options }
    end
  end

  describe '#qualified_name' do
    let(:expected) { record_class.name.underscore.pluralize }

    include_examples 'should define reader',
      :qualified_name,
      -> { be == expected }

    context 'when initialized with qualified_name: a String' do
      let(:qualified_name) { 'tomes' }
      let(:constructor_options) do
        super().merge(qualified_name: qualified_name)
      end

      it { expect(collection.qualified_name).to be == qualified_name }
    end

    context 'when initialized with qualified_name: a Symbol' do
      let(:qualified_name) { :tomes }
      let(:constructor_options) do
        super().merge(qualified_name: qualified_name)
      end

      it { expect(collection.qualified_name).to be == qualified_name.to_s }
    end

    context 'when initialized with resource_class: a scoped Class' do
      let(:record_class) { Spec::ScopedBook }

      example_class 'Spec::ScopedBook', Book

      it { expect(collection.qualified_name).to be == expected }
    end
  end

  describe '#record_class' do
    include_examples 'should define reader',
      :record_class,
      -> { record_class }
  end
end
