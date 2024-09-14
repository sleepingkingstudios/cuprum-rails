# frozen_string_literal: true

require 'cuprum/rails/action'
require 'cuprum/rails/records/repository'
require 'cuprum/rails/request'
require 'cuprum/rails/rspec/contracts/action_contracts'

RSpec.describe Cuprum::Rails::Action do
  include Cuprum::Rails::RSpec::Contracts::ActionContracts

  subject(:action) { described_class.new }

  let(:params)  { {} }
  let(:request) { instance_double(ActionDispatch::Request, params:) }

  include_contract 'should be an action'

  describe '.build' do
    let(:request)    { Cuprum::Rails::Request.new }
    let(:repository) { Cuprum::Rails::Records::Repository.new }
    let(:resource)   { Cuprum::Rails::Resource.new(name: 'books') }
    let(:options)    { { optional: 'value' } }
    let(:delegate)   { instance_double(Proc, call: nil) }
    let(:implementation) do
      delegate_proc = delegate

      ->(*args, **kwargs) { delegate_proc.call(*args, **kwargs) }
    end
    let(:action_class) { described_class.build(&implementation) }

    def call_action
      action_class.new.call(
        request:,
        repository:,
        resource:,
        **options
      )
    end

    before(:example) do
      allow(SleepingKingStudios::Tools::Toolbelt.instance.core_tools)
        .to receive(:deprecate)
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:build)
        .with(0).arguments
        .and_a_block
    end

    it { expect(action_class).to be_a Class }

    it { expect(action_class).to be < described_class }

    it 'should pass the parameters to the implementation' do # rubocop:disable RSpec/ExampleLength
      call_action

      expect(delegate).to have_received(:call).with(
        request:,
        repository:,
        resource:,
        **options
      )
    end

    context 'when the implementation returns a failing result' do
      let(:expected_error) do
        Cuprum::Error.new(message: 'Something went wrong')
      end
      let(:result) { Cuprum::Result.new(error: expected_error) }
      let(:implementation) do
        returned = result

        ->(*, **) { returned }
      end

      it 'should return a failing result' do
        expect(call_action)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    context 'when the implementation returns a passing result' do
      let(:expected_value) { { 'ok' => true } }
      let(:result)         { Cuprum::Result.new(value: expected_value) }
      let(:implementation) do
        returned = result

        ->(*, **) { returned }
      end

      it 'should return a passing result' do
        expect(call_action)
          .to be_a_passing_result
          .with_value(expected_value)
      end
    end
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:command_class)
        .and_a_block
    end

    describe 'with command_class: value and a block' do
      let(:command_class)  { Cuprum::Rails::Command }
      let(:implementation) { -> { { ok: true } } }
      let(:error_message) do
        'implementation block overrides command_class parameter'
      end

      it 'should raise an exception' do
        expect { described_class.new(command_class:, &implementation) }
          .to raise_error ArgumentError, error_message
      end
    end
  end

  describe '#call' do
    it 'should define the method' do
      expect(action)
        .to be_callable
        .with(0).arguments
        .and_keywords(:repository, :request, :resource)
        .and_any_keywords
    end

    it 'should return a passing result' do
      expect(action.call(request:))
        .to be_a_passing_result(Cuprum::Rails::Result)
        .with_value(nil)
    end

    context 'when initialized with a command class' do
      subject(:action) do
        described_class.new(command_class: Spec::ExampleCommand)
      end

      let(:repository)     { Cuprum::Rails::Records::Repository.new }
      let(:resource)       { Cuprum::Rails::Resource.new(name: 'books') }
      let(:params)         { { 'book' => { 'title' => 'Gideon the Ninth' } } }
      let(:expected_value) { params.merge('ok' => true) }

      example_class 'Spec::ExampleCommand', Cuprum::Rails::Command do |klass|
        klass.define_method(:process) do |**params|
          params.merge('ok' => true)
        end
      end

      it 'should initialize the command class' do
        allow(Spec::ExampleCommand).to receive(:new).and_call_original

        action.call(repository:, request:, resource:)

        expect(Spec::ExampleCommand)
          .to have_received(:new)
          .with(repository:, resource:)
      end

      it 'should return a passing result' do
        expect(action.call(repository:, request:, resource:))
          .to be_a_passing_result(Cuprum::Rails::Result)
          .with_value(expected_value)
      end
    end

    context 'when initialized with an implementation' do
      subject(:action) { described_class.new(&implementation) }

      let(:implementation) { ->(**params) { params.merge(ok: true) } }
      let(:repository)     { Cuprum::Rails::Records::Repository.new }
      let(:resource)       { Cuprum::Rails::Resource.new(name: 'books') }
      let(:expected_value) do
        {
          ok:         true,
          option:     'value',
          repository:,
          request:,
          resource:
        }
      end

      it 'should return a passing result' do
        expect(action.call(option: 'value', repository:, request:, resource:))
          .to be_a_passing_result(Cuprum::Rails::Result)
          .with_value(expected_value)
      end
    end
  end

  describe '#options' do
    context 'when called with options' do
      let(:options) { { key: 'value' } }

      before(:example) { action.call(request:, **options) }

      it { expect(action.options).to be == options }
    end
  end

  describe '#params' do
    context 'when called with a request' do
      before(:example) { action.call(request:) }

      it { expect(action.params).to be == params }
    end

    context 'when called with a request with parameters' do
      let(:params) do
        {
          'book' => {
            'title' => 'Tamsyn Muir'
          },
          'key'  => 'value'
        }
      end

      before(:example) { action.call(request:) }

      it { expect(action.params).to be == params }
    end
  end

  describe '#repository' do
    include_examples 'should define reader', :repository

    context 'when called with a repository' do
      let(:repository) { Cuprum::Rails::Records::Repository.new }

      before(:example) { action.call(repository:, request:) }

      it { expect(action.repository).to be repository }
    end
  end

  describe '#request' do
    context 'when called with a request' do
      before(:example) { action.call(request:) }

      it { expect(action.request).to be == request }
    end
  end

  describe '#resource' do
    context 'when called with a resource' do
      let(:resource) { Cuprum::Rails::Resource.new(name: 'books') }

      before(:example) { action.call(request:, resource:) }

      it { expect(action.resource).to be == resource }
    end
  end
end
