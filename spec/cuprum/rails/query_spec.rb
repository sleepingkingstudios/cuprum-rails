# frozen_string_literal: true

require 'cuprum/collections/rspec/query_contract'

require 'cuprum/rails/query'

require 'support/book'
require 'support/tome'

RSpec.describe Cuprum::Rails::Query do
  subject(:query) do
    described_class.new(record_class, native_query: native_query)
  end

  let(:data)          { [] }
  let(:native_query)  { nil }
  let(:record_class)  { Book }
  let(:default_order) { { record_class.primary_key => :asc } }
  let(:expected_data) do
    matching_data.map do |attributes|
      Book.where(attributes).first
    end
  end

  def add_item_to_collection(item)
    Book.create!(item)
  end

  before(:example) do
    data.each { |attributes| add_item_to_collection(attributes) }
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(1).argument
        .and_keywords(:native_query)
    end
  end

  include_contract Cuprum::Collections::RSpec::QUERY_CONTRACT

  describe '#each' do
    let(:mock_query) do
      instance_double(
        ActiveRecord::Relation,
        each:  [].to_enum,
        order: nil,
        to_a:  []
      )
        .tap { |mock| allow(mock).to receive(:order).and_return(mock) }
    end

    before(:example) do
      allow(record_class).to receive(:all).and_return(mock_query)
    end

    it 'should delegate to the native query' do
      query.each

      expect(mock_query).to have_received(:each).with(no_args)
    end

    context 'when initialized with a native query' do
      let(:native_query) { mock_query }

      it 'should delegate to the native query' do
        query.each

        expect(native_query).to have_received(:each).with(no_args)
      end
    end
  end

  describe '#native_query' do
    include_examples 'should have private reader',
      :native_query,
      -> { record_class.all.order({ 'id' => :asc }) }
  end

  describe '#order' do
    context 'when the record class has a custom primary key' do
      it { expect(query.order).to be == default_order }
    end
  end

  describe '#record_class' do
    include_examples 'should have reader', :record_class, -> { record_class }
  end

  describe '#to_a' do
    let(:mock_query) do
      instance_double(
        ActiveRecord::Relation,
        each:  [].to_enum,
        order: nil,
        to_a:  []
      )
        .tap { |mock| allow(mock).to receive(:order).and_return(mock) }
    end

    before(:example) do
      allow(record_class).to receive(:all).and_return(mock_query)
    end

    it 'should delegate to the native query' do
      query.to_a

      expect(mock_query).to have_received(:to_a).with(no_args)
    end

    context 'when initialized with a native query' do
      let(:native_query) { mock_query }

      it 'should delegate to the native query' do
        query.to_a

        expect(native_query).to have_received(:to_a).with(no_args)
      end
    end
  end
end
