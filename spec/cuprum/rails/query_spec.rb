# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/query_examples'

require 'cuprum/rails/query'

require 'support/book'
require 'support/tome'

RSpec.describe Cuprum::Rails::Query do
  include Cuprum::Collections::RSpec::Deferred::QueryExamples

  shared_context 'with a mock native query' do
    let(:mock_query) do
      instance_double(
        ActiveRecord::Relation,
        each:  [].to_enum,
        order: nil,
        to_a:  []
      )
        .tap do |mock|
          allow(mock)
            .to receive(:is_a?)
            .with(ActiveRecord::Relation)
            .and_return(true)
        end # rubocop:disable Style/MultilineBlockChain
        .tap { |mock| allow(mock).to receive(:order).and_return(mock) }
    end

    before(:example) do
      allow(record_class).to receive(:all).and_return(mock_query)
    end
  end

  subject(:query) do
    described_class.new(
      record_class,
      native_query:,
      scope:        initial_scope
    )
  end

  let(:data)          { [] }
  let(:filtered_data) { data }
  let(:ordered_data) do
    filtered_data.sort_by { |item| item[record_class.primary_key.to_s] }
  end
  let(:matching_data) { ordered_data }
  let(:expected_data) do
    matching_data.map do |attributes|
      Book.where(attributes).first
    end
  end
  let(:native_query)  { nil }
  let(:record_class)  { Book }
  let(:initial_scope) { nil }
  let(:default_order) { { record_class.primary_key => :asc } }

  define_method :add_item_to_collection do |item|
    Book.create!(item)
  end

  before(:example) do
    data.each { |attributes| add_item_to_collection(attributes) }

    allow(SleepingKingStudios::Tools::Toolbelt.instance.core_tools)
      .to receive(:deprecate)
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(1).argument
        .and_keywords(:native_query)
    end

    it 'should print a deprecation warning' do # rubocop:disable RSpec/ExampleLength
      described_class.new(record_class)

      expect(SleepingKingStudios::Tools::Toolbelt.instance.core_tools)
        .to have_received(:deprecate)
        .with(
          described_class.name,
          'Use Cuprum::Rails::Records::Query instead'
        )
    end
  end

  include_deferred 'should be a Query'

  describe '#each' do
    include_context 'with a mock native query'

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
      -> { record_class.all }
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
    include_context 'with a mock native query'

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
