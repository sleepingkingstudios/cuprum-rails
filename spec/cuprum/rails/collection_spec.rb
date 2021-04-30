# frozen_string_literal: true

require 'cuprum/collections/rspec/collection_contract'

require 'cuprum/rails/collection'
require 'cuprum/rails/commands'

require 'support/book'

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

  include_contract Cuprum::Collections::RSpec::COLLECTION_CONTRACT

  describe '#collection_name' do
    let(:expected) { record_class.name.underscore.pluralize }

    include_examples 'should define reader',
      :collection_name,
      -> { be == expected }

    context 'when initialized with collection_name: string' do
      let(:collection_name) { 'books' }
      let(:constructor_options) do
        super().merge(collection_name: collection_name)
      end

      it { expect(collection.collection_name).to be == collection_name }
    end

    context 'when initialized with collection_name: symbol' do
      let(:collection_name) { :books }
      let(:constructor_options) do
        super().merge(collection_name: collection_name)
      end

      it { expect(collection.collection_name).to be == collection_name.to_s }
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

  describe '#record_class' do
    include_examples 'should define reader',
      :record_class,
      -> { record_class }
  end
end
