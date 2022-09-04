# frozen_string_literal: true

require 'stannum/constraints/presence'
require 'stannum/contracts/hash_contract'

require 'cuprum/rails/action'
require 'cuprum/rails/actions/parameter_validation'

RSpec.describe Cuprum::Rails::Actions::ParameterValidation do
  subject(:action) { described_class.new(resource: resource) }

  shared_context 'when .validate_parameters is called with a block' do
    before(:example) do
      described_class.validate_parameters(&implementation)
    end
  end

  shared_context 'when .validate_parameters is called with a contract' do
    let(:contract) do
      Stannum::Contracts::HashContract.new(&implementation)
    end

    before(:example) do
      described_class.validate_parameters(contract)
    end
  end

  shared_context 'when the action defines #parameters_contract' do
    let(:contract) do
      Stannum::Contracts::HashContract.new(&implementation)
    end

    before(:example) do
      parameters_contract = contract

      described_class.define_method(:parameters_contract) do
        parameters_contract
      end
    end
  end

  let(:described_class) { Spec::Action }
  let(:resource)        { Cuprum::Rails::Resource.new(resource_name: 'books') }
  let(:implementation) do
    -> { key 'book_id', Stannum::Constraints::Presence.new }
  end

  example_class 'Spec::Action', Cuprum::Rails::Action do |klass|
    klass.include Cuprum::Rails::Actions::ParameterValidation # rubocop:disable RSpec/DescribedClass

    klass.define_method(:process) do |request:|
      super(request: request)

      { 'ok' => true }
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

  describe '#call' do
    let(:params)  { {} }
    let(:request) { Cuprum::Rails::Request.new(params: params) }

    it 'should return a passing result' do
      expect(action.call(request: request))
        .to be_a_passing_result
        .with_value({ 'ok' => true })
    end

    wrap_context 'when .validate_parameters is called with a block' do
      describe 'when the parameters do not match the contract' do
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

        it 'should return a failing result' do
          expect(action.call(request: request))
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'when the parameters match the contract' do
        let(:params) { { 'book_id' => '00000000-0000-0000-0000-000000000000' } }

        it 'should return a passing result' do
          expect(action.call(request: request))
            .to be_a_passing_result
            .with_value({ 'ok' => true })
        end
      end

      describe 'when request has extra parameters' do
        let(:params) do
          {
            'book_id'  => '00000000-0000-0000-0000-000000000000',
            'checksum' => 0
          }
        end

        it 'should return a passing result' do
          expect(action.call(request: request))
            .to be_a_passing_result
            .with_value({ 'ok' => true })
        end
      end
    end

    # rubocop:disable RSpec/RepeatedExampleGroupBody
    wrap_context 'when .validate_parameters is called with a contract' do
      describe 'when the parameters do not match the contract' do
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

        it 'should return a failing result' do
          expect(action.call(request: request))
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'when the parameters match the contract' do
        let(:params) { { 'book_id' => '00000000-0000-0000-0000-000000000000' } }

        it 'should return a passing result' do
          expect(action.call(request: request))
            .to be_a_passing_result
            .with_value({ 'ok' => true })
        end
      end
    end

    wrap_context 'when the action defines #parameters_contract' do
      describe 'when the parameters do not match the contract' do
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

        it 'should return a failing result' do
          expect(action.call(request: request))
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'when the parameters match the contract' do
        let(:params) { { 'book_id' => '00000000-0000-0000-0000-000000000000' } }

        it 'should return a passing result' do
          expect(action.call(request: request))
            .to be_a_passing_result
            .with_value({ 'ok' => true })
        end
      end
    end
    # rubocop:enable RSpec/RepeatedExampleGroupBody
  end

  describe '#parameters_contract' do
    include_examples 'should define private reader', :parameters_contract, nil

    wrap_context 'when .validate_parameters is called with a block' do
      it 'should return the contract' do
        expect(action.send :parameters_contract)
          .to be_a Stannum::Contracts::IndifferentHashContract
      end
    end

    wrap_context 'when .validate_parameters is called with a contract' do
      it 'should return the contract' do
        expect(action.send :parameters_contract).to be contract
      end
    end
  end

  describe '#validate_parameters' do
    let(:params)  { {} }
    let(:request) { Cuprum::Rails::Request.new(params: params) }
    let(:contract) do
      Stannum::Contracts::HashContract.new(&implementation)
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

      before(:example) { action.call(request: request) }

      it 'should return a failing result' do
        expect(action.send(:validate_parameters, contract))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with a contract that matches the parameters' do
      let(:params) { { 'book_id' => '00000000-0000-0000-0000-000000000000' } }

      before(:example) { action.call(request: request) }

      it 'should return a passing result' do
        expect(action.send(:validate_parameters, contract))
          .to be_a_passing_result
      end
    end
  end
end
