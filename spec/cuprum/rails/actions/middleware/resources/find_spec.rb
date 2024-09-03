# frozen_string_literal: true

require 'cuprum/rails/actions/middleware/resources/find'
require 'cuprum/rails/request'
require 'cuprum/rails/repository'
require 'cuprum/rails/resource'

require 'support/book'

RSpec.describe Cuprum::Rails::Actions::Middleware::Resources::Find do
  subject(:middleware) { described_class.new(**constructor_options) }

  let(:resource_params)     { { name: 'books' } }
  let(:constructor_options) { resource_params }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:only_form_actions)
        .and_any_keywords
    end

    describe 'with invalid resource params' do
      let(:resource_params) { {} }
      let(:error_message) do
        "name or entity class can't be blank"
      end

      it 'should raise an exception' do
        expect { described_class.new(**constructor_options) }
          .to raise_error ArgumentError, error_message
      end
    end
  end

  describe '#call' do
    shared_examples 'should return the resource values' do
      it 'should return the resource values' do
        expect(call_command)
          .to be_a_result
          .with_status(expected_status)
          .and_value(expected_value)
      end

      context 'when there are many resource values' do
        let(:books) do
          attributes = [
            { title: 'Gideon the Ninth', author: 'Tamsyn Muir' },
            { title: 'Harrow the Ninth', author: 'Tamsyn Muir' },
            { title: 'Nona the Ninth',   author: 'Tamsyn Muir' }
          ]

          attributes.map { |hsh| Book.new(hsh) }
        end
        let(:expected_value) do
          super().merge({ 'books' => match_array(books) })
        end

        before(:example) { books.map(&:save!) }

        it 'should return the resource values', :aggregate_failures do
          result = call_command

          expect(result).to be_a_result.with_status(expected_status)
          expect(result.value).to deep_match(expected_value)
        end
      end
    end

    let(:next_result) do
      Cuprum::Result.new(value: { 'ok' => true })
    end
    let(:next_command) do
      instance_double(Cuprum::Command, call: next_result)
    end
    let(:request)         { Cuprum::Rails::Request.new(http_method: :get) }
    let(:repository)      { Cuprum::Rails::Repository.new }
    let(:resource)        { Cuprum::Rails::Resource.new(name: 'authors') }
    let(:options)         { {} }
    let(:expected_status) { next_result.status }
    let(:expected_value)  { next_result.value.merge({ 'books' => [] }) }

    def call_command
      middleware.call(
        next_command,
        repository:,
        request:,
        resource:,
        **options
      )
    end

    it 'should define the method' do
      expect(middleware)
        .to be_callable
        .with(1).argument
        .and_keywords(:repository, :request, :resource)
        .and_any_keywords
    end

    it 'should call the next command' do # rubocop:disable RSpec/ExampleLength
      call_command

      expect(next_command)
        .to have_received(:call)
        .with(
          repository:,
          request:,
          resource:,
          **options
        )
    end

    include_examples 'should return the resource values'

    describe 'with a non-GET request' do
      let(:request) { Cuprum::Rails::Request.new(http_method: :post) }

      include_examples 'should return the resource values'

      context 'when the next command returns a failing result' do
        let(:next_result) do
          Cuprum::Result.new(status: :failure, value: { 'ok' => false })
        end

        include_examples 'should return the resource values'
      end
    end

    context 'when the next command returns a failing result' do
      let(:next_result) do
        Cuprum::Result.new(status: :failure, value: { 'ok' => false })
      end

      include_examples 'should return the resource values'
    end

    context 'when initialized with only_form_actions: true' do
      let(:constructor_options) { super().merge(only_form_actions: true) }

      include_examples 'should return the resource values'

      describe 'with a non-GET request' do
        let(:request) { Cuprum::Rails::Request.new(http_method: :post) }

        it 'should not query for the resource' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(next_result.value)
        end

        context 'when the next command returns a failing result' do
          let(:next_result) do
            Cuprum::Result.new(status: :failure, value: { 'ok' => false })
          end

          include_examples 'should return the resource values'
        end
      end

      context 'when the next command returns a failing result' do
        let(:next_result) do
          Cuprum::Result.new(status: :failure, value: { 'ok' => false })
        end

        include_examples 'should return the resource values'
      end
    end

    context 'when initialized with singular: true' do
      let(:constructor_options) { super().merge(singular: true) }
      let(:expected_value)      { next_result.value.merge({ 'book' => nil }) }

      it 'should return the resource value' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_value)
      end

      context 'when the resource value exists' do
        let(:book) do
          Book.new(title: 'Gideon the Ninth', author: 'Tamsyn Muir')
        end
        let(:expected_value) do
          super().merge({ 'book' => book })
        end

        before(:example) { book.save! }

        it 'should return the resource value' do
          expect(call_command)
            .to be_a_result
            .with_status(expected_status)
            .and_value(expected_value)
        end
      end
    end
  end

  describe '#only_form_actions?' do
    include_examples 'should define predicate', :only_form_actions?, false

    context 'when initialized with only_form_actions: false' do
      let(:constructor_options) { super().merge(only_form_actions: false) }

      it { expect(middleware.only_form_actions?).to be false }
    end

    context 'when initialized with only_form_actions: true' do
      let(:constructor_options) { super().merge(only_form_actions: true) }

      it { expect(middleware.only_form_actions?).to be true }
    end
  end

  describe '#resource' do
    let(:resource) { middleware.resource }

    include_examples 'should define reader', :resource

    it { expect(resource).to be_a Cuprum::Collections::Resource }

    it { expect(resource.name).to be == 'books' }

    context 'when initialized with resource params' do
      let(:resource_params) do
        super().merge(
          primary_key_type: String,
          qualified_name:   'spec/scoped_books'
        )
      end

      it { expect(resource.primary_key_type).to be String }

      it { expect(resource.qualified_name).to be == 'spec/scoped_books' }
    end
  end
end
