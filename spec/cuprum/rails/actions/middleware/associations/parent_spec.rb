# frozen_string_literal: true

require 'cuprum/rails/actions/middleware/associations/parent'
require 'cuprum/rails/records/repository'
require 'cuprum/rails/request'
require 'cuprum/rails/resource'

require 'support/book'
require 'support/chapter'
require 'support/cover'

RSpec.describe Cuprum::Rails::Actions::Middleware::Associations::Parent do
  subject(:middleware) { described_class.new(**constructor_options) }

  let(:association_params)  { { name: 'book' } }
  let(:constructor_options) { association_params }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_any_keywords
    end

    describe 'with invalid association params' do
      let(:association_params) { {} }
      let(:error_message) do
        "name or entity class can't be blank"
      end

      it 'should raise an exception' do
        expect { described_class.new(**constructor_options) }
          .to raise_error ArgumentError, error_message
      end
    end
  end

  describe '#association' do
    let(:association) { middleware.association }
    let(:association_class) do
      Cuprum::Collections::Associations::BelongsTo
    end

    include_examples 'should define reader', :association

    it { expect(association).to be_a association_class }

    it { expect(association.name).to be == 'book' }
  end

  describe '#association_type' do
    include_examples 'should define reader', :association_type, :belongs_to
  end

  describe '#call' do
    shared_context 'with a valid book id' do
      let(:book) do
        Book.create(
          'title'  => 'Gideon the Ninth',
          'author' => 'Tamsyn Muir'
        )
      end
      let(:book_id) { book.id }
      let(:params)  { super().merge('book_id' => book_id) }
    end

    shared_examples 'should call the next command' do
      it 'should call the next command' do # rubocop:disable RSpec/ExampleLength
        call_command

        expect(next_command).to have_received(:call).with(
          repository:,
          request:,
          resource:,
          **options
        )
      end

      context 'when called with custom options' do
        let(:options) { super().merge('custom_option' => 'custom value') }

        it 'should call the next command' do # rubocop:disable RSpec/ExampleLength
          call_command

          expect(next_command).to have_received(:call).with(
            repository:,
            request:,
            resource:,
            **options
          )
        end
      end
    end

    let(:next_result)  { Cuprum::Result.new(value: { 'ok' => true }) }
    let(:next_command) { instance_double(Cuprum::Command, call: next_result) }
    let(:params)       { {} }
    let(:request)      { Cuprum::Rails::Request.new(params:) }
    let(:repository)   { Cuprum::Rails::Records::Repository.new }
    let(:resource)     { Cuprum::Rails::Resource.new(name: 'chapters') }
    let(:options)      { {} }

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

    context 'when the parameter is missing' do
      let(:params) { {} }
      let(:expected_error) do
        Cuprum::Rails::Errors::MissingParameter.new(
          parameter_name: 'book_id',
          parameters:     params
        )
      end

      it 'should not call the next command' do
        call_command

        expect(next_command).not_to have_received(:call)
      end

      it 'should return a failing result' do
        expect(call_command)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    context 'when the association is not found' do
      let(:book_id) { (Book.order(:id).last&.id || -1) + 1 }
      let(:params)  { super().merge('book_id' => book_id) }
      let(:expected_error) do
        Cuprum::Collections::Errors::NotFound.new(
          attribute_name:  'id',
          attribute_value: book_id,
          collection_name: 'book',
          primary_key:     true
        )
      end

      it 'should not call the next command' do
        call_command

        expect(next_command).not_to have_received(:call)
      end

      it 'should return a failing result' do
        expect(call_command)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    context 'when the next command does not return a value' do
      include_context 'with a valid book id'

      let(:next_result) { Cuprum::Result.new }

      include_examples 'should call the next command'

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(nil)
      end
    end

    context 'when the next command does not return entities' do
      include_context 'with a valid book id'

      let(:next_result)    { Cuprum::Result.new(value: { 'ok' => true }) }
      let(:expected_value) { next_result.value.merge('book' => book) }

      include_examples 'should call the next command'

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_value)
      end
    end

    context 'when the next command returns entities' do
      include_context 'with a valid book id'

      let(:chapters) do
        Array.new(3) do |index|
          Chapter.create('book_id' => book_id, 'chapter_index' => index)
        end
      end
      let(:next_result) do
        Cuprum::Result.new(value: { 'ok' => true, 'chapters' => chapters })
      end
      let(:expected_value) { next_result.value.merge('book' => book) }

      def cached_values(entities)
        entities.map { |entity| entity.send(:association_instance_get, 'book') }
      end

      include_examples 'should call the next command'

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_value)
      end

      it 'should cache the association' do
        value = call_command.value

        expect(cached_values(value['chapters'])).to be == [book, book, book]
      end
    end

    context 'when the next command returns a failing result' do
      include_context 'with a valid book id'

      let(:next_error) { Cuprum::Error.new(message: 'Something went wrong.') }
      let(:next_value) { { 'ok' => false } }
      let(:next_result) do
        Cuprum::Result.new(error: next_error, value: next_value)
      end
      let(:expected_value) { next_result.value.merge('book' => book) }

      include_examples 'should call the next command'

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_failing_result
          .with_error(next_error)
          .and_value(expected_value)
      end
    end

    context 'when initialized with a singular resource' do
      let(:resource) do
        Cuprum::Rails::Resource.new(name: 'cover', singular: true)
      end

      context 'when the next command does not return a value' do
        include_context 'with a valid book id'

        let(:next_result) { Cuprum::Result.new }

        include_examples 'should call the next command'

        it 'should return a passing result' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(nil)
        end
      end

      context 'when the next command does not return entities' do
        include_context 'with a valid book id'

        let(:next_result)    { Cuprum::Result.new(value: { 'ok' => true }) }
        let(:expected_value) { next_result.value.merge('book' => book) }

        include_examples 'should call the next command'

        it 'should return a passing result' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(expected_value)
        end
      end

      context 'when the next command returns an entity' do
        include_context 'with a valid book id'

        let(:cover) do
          Cover.create('book_id' => book_id, 'artist' => 'Tommy Arnold')
        end
        let(:next_result) do
          Cuprum::Result.new(value: { 'ok' => true, 'cover' => cover })
        end
        let(:expected_value) { next_result.value.merge('book' => book) }

        def cached_value(entity)
          entity.send(:association_instance_get, 'book')
        end

        include_examples 'should call the next command'

        it 'should return a passing result' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(expected_value)
        end

        it 'should cache the association' do
          value = call_command.value

          expect(cached_value(value['cover'])).to be == book
        end
      end
    end
  end
end
