# frozen_string_literal: true

require 'cuprum/rails/actions/middleware/resources/query'
require 'cuprum/rails/request'
require 'cuprum/rails/repository'
require 'cuprum/rails/resource'

RSpec.describe Cuprum::Rails::Actions::Middleware::Resources::Query do
  subject(:middleware) { described_class.new(**constructor_options) }

  let(:resource_params)     { { name: 'books' } }
  let(:constructor_options) { resource_params }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
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
    let(:next_result)  { Cuprum::Result.new(value: { 'ok' => true }) }
    let(:next_command) { instance_double(Cuprum::Command, call: next_result) }
    let(:request)      { Cuprum::Rails::Request.new }
    let(:repository)   { Cuprum::Rails::Repository.new }
    let(:resource)     { Cuprum::Rails::Resource.new(name: 'authors') }
    let(:options)      { {} }

    def call_command
      middleware.call(
        next_command,
        repository: repository,
        request:    request,
        resource:   resource,
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
          repository: repository,
          request:    request,
          resource:   resource,
          **options
        )
    end

    it 'should return the next command result' do
      expect(call_command)
        .to be_a_passing_result
        .with_value({ 'ok' => true })
    end

    context 'when called with custom options' do
      let(:options) do
        super().merge('custom_option' => 'custom value')
      end

      it 'should call the next command' do # rubocop:disable RSpec/ExampleLength
        call_command

        expect(next_command)
          .to have_received(:call)
          .with(
            repository: repository,
            request:    request,
            resource:   resource,
            **options
          )
      end
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
