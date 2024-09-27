# frozen_string_literal: true

require 'cuprum/rails/action'
require 'cuprum/rails/records/repository'
require 'cuprum/rails/request'
require 'cuprum/rails/rspec/contracts/action_contracts'

RSpec.describe Cuprum::Rails::Action do
  include Cuprum::Rails::RSpec::Contracts::ActionContracts

  subject(:action) do
    described_class.new(**constructor_options, &implementation)
  end

  shared_context 'when .validate_parameters is called with a block' do
    include_context 'with an action subclass'

    before(:example) do
      described_class.validate_parameters(&contract_block)
    end
  end

  shared_context 'when .validate_parameters is called with a contract' do
    include_context 'with an action subclass'

    let(:contract) do
      Stannum::Contracts::HashContract
        .new(allow_extra_keys: true, &contract_block)
    end

    before(:example) do
      described_class.validate_parameters(contract)
    end
  end

  shared_context 'when initialized with parameters_contract: value' do
    let(:contract) do
      Stannum::Contracts::HashContract
        .new(allow_extra_keys: true, &contract_block)
    end
    let(:constructor_options) do
      super().merge(parameters_contract: contract)
    end
  end

  shared_context 'when the action defines #parameters_contract' do
    include_context 'with an action subclass'

    let(:contract) do
      Stannum::Contracts::HashContract
        .new(allow_extra_keys: true, &contract_block)
    end

    before(:example) do
      parameters_contract = contract

      described_class.define_method(:parameters_contract) do
        parameters_contract
      end
    end
  end

  shared_context 'with an action subclass' do
    let(:described_class) { Spec::ValidatedAction }

    example_class 'Spec::ValidatedAction', Cuprum::Rails::Action # rubocop:disable RSpec/DescribedClass
  end

  let(:params)  { {} }
  let(:request) { instance_double(ActionDispatch::Request, params:) }
  let(:contract_block) do
    -> { key 'book_id', Stannum::Constraints::Presence.new }
  end
  let(:constructor_options) { {} }
  let(:implementation)      { nil }

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

    it 'should print a deprecation warning' do # rubocop:disable RSpec/ExampleLength
      call_action

      expect(SleepingKingStudios::Tools::Toolbelt.instance.core_tools)
        .to have_received(:deprecate)
        .with(
          'Cuprum::Rails::Action.build',
          message: 'Use Action.subclass instead'
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

  describe '.validate_parameters' do
    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:validate_parameters)
        .with(0..1).arguments
        .and_a_block
    end
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:command_class, :parameters_contract)
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
    shared_examples 'should implement parameter validation' \
    do |expected_status: :success|
      # rubocop:disable RSpec/RepeatedExampleGroupBody
      wrap_context 'when .validate_parameters is called with a block' do
        include_examples 'should validate the parameters', expected_status:
      end

      wrap_context 'when .validate_parameters is called with a contract' do
        include_examples 'should validate the parameters', expected_status:
      end

      wrap_context 'when initialized with parameters_contract: value' do
        include_examples 'should validate the parameters', expected_status:
      end

      wrap_context 'when the action defines #parameters_contract' do
        include_examples 'should validate the parameters', expected_status:
      end
      # rubocop:enable RSpec/RepeatedExampleGroupBody
    end

    shared_examples 'should validate the parameters' do |expected_status:|
      describe 'with invalid params' do
        let(:expected_errors) do
          Stannum::Errors
            .new
            .tap do |err|
              err['book_id'].add(Stannum::Constraints::Presence::TYPE)
            end
        end
        let(:expected_error) do
          Cuprum::Rails::Errors::InvalidParameters
            .new(errors: expected_errors)
        end

        it 'should return a failing result' do
          expect(call_action)
            .to be_a_failing_result(Cuprum::Rails::Result)
            .with_error(expected_error)
        end
      end

      describe 'with valid params' do
        let(:params) do
          super().merge('book_id' => 0)
        end

        if expected_status == :success
          it 'should return a passing result' do
            expect(call_action)
              .to be_a_passing_result(Cuprum::Rails::Result)
              .with_value(expected_value)
          end
        else
          it 'should return a failing result' do
            expect(call_action)
              .to be_a_failing_result(Cuprum::Rails::Result)
              .with_error(expected_error)
          end
        end
      end
    end

    let(:expected_value) { nil }
    let(:expected_error) do
      Cuprum::Errors::CommandNotImplemented.new(command: action)
    end

    def call_action
      action.call(request:)
    end

    it 'should define the method' do
      expect(action)
        .to be_callable
        .with(0).arguments
        .and_keywords(:repository, :request, :resource)
        .and_any_keywords
    end

    it 'should return a failing result' do
      expect(call_action)
        .to be_a_failing_result(Cuprum::Rails::Result)
        .with_error(expected_error)
    end

    include_examples 'should implement parameter validation',
      expected_status: :failure

    context 'when initialized with a command class' do
      let(:constructor_options) do
        super().merge(command_class: Spec::ExampleCommand)
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

      def call_action
        action.call(repository:, request:, resource:)
      end

      it 'should initialize the command class' do
        allow(Spec::ExampleCommand).to receive(:new).and_call_original

        call_action

        expect(Spec::ExampleCommand)
          .to have_received(:new)
          .with(repository:, resource:)
      end

      it 'should return a passing result' do
        expect(call_action)
          .to be_a_passing_result(Cuprum::Rails::Result)
          .with_value(expected_value)
      end

      include_examples 'should implement parameter validation'
    end

    context 'when initialized with an implementation' do
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

      def call_action
        action.call(option: 'value', repository:, request:, resource:)
      end

      it 'should return a passing result' do
        expect(call_action)
          .to be_a_passing_result(Cuprum::Rails::Result)
          .with_value(expected_value)
      end

      include_examples 'should implement parameter validation'
    end
  end

  describe '#options' do
    context 'when called with options' do
      let(:options) { { key: 'value' } }

      before(:example) { action.call(request:, **options) }

      it { expect(action.options).to be == options }
    end
  end

  describe '#parameters_contract' do
    include_examples 'should define reader', :parameters_contract, nil

    wrap_context 'when .validate_parameters is called with a block' do
      it 'should return the contract' do
        expect(action.parameters_contract)
          .to be_a Cuprum::Rails::Constraints::ParametersContract
      end
    end

    # rubocop:disable RSpec/RepeatedExampleGroupBody
    wrap_context 'when .validate_parameters is called with a contract' do
      it 'should return the contract' do
        expect(action.parameters_contract).to be contract
      end
    end

    wrap_context 'when initialized with parameters_contract: value' do
      it 'should return the contract' do
        expect(action.parameters_contract).to be contract
      end
    end
    # rubocop:enable RSpec/RepeatedExampleGroupBody
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

  describe '#validate_parameters' do
    let(:params) { {} }
    let(:contract) do
      Stannum::Contracts::HashContract.new(&contract_block)
    end

    it 'should define the private method' do
      expect(action).to respond_to(:validate_parameters, true).with(1).argument
    end

    describe 'with a contract that does not match the parameters' do
      let(:expected_errors) do
        Stannum::Errors
          .new
          .tap do |err|
            err['book_id'].add(Stannum::Constraints::Presence::TYPE)
          end
      end
      let(:expected_error) do
        Cuprum::Rails::Errors::InvalidParameters.new(errors: expected_errors)
      end

      before(:example) { action.call(request:) }

      it 'should return a failing result' do
        expect(action.send(:validate_parameters, contract))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with a contract that matches the parameters' do
      let(:params) { { 'book_id' => '00000000-0000-0000-0000-000000000000' } }

      before(:example) { action.call(request:) }

      it 'should return a passing result' do
        expect(action.send(:validate_parameters, contract))
          .to be_a_passing_result
      end
    end
  end
end
