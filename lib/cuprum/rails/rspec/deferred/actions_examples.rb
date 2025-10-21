# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred'

require 'cuprum/rails/rspec/deferred'

module Cuprum::Rails::RSpec::Deferred
  # Deferred examples for validating custom Action classes.
  module ActionsExamples
    include RSpec::SleepingKingStudios::Deferred::Provider
    include RSpec::SleepingKingStudios::Matchers::Macros

    deferred_context 'with parameters for an action' do
      let(:repository) do
        next super() if defined?(super())

        Cuprum::Rails::Records::Repository.new
      end
      let(:resource) do
        next super() if defined?(super())

        Cuprum::Rails::Resource.new(name: 'books')
      end
      let(:params) do
        next super() if defined?(super())

        {}
      end
      let(:request) do
        next super() if defined?(super())

        instance_double(Cuprum::Rails::Request, params:)
      end

      define_method :call_action do
        action.call(repository:, request:, resource:)
      end
    end

    deferred_examples 'should implement the action methods' \
    do |command_class: nil|
      describe '.new' do
        it { expect(described_class).to be_constructible.with(0).arguments }
      end

      describe '#call' do
        it 'should define the method' do
          expect(action)
            .to be_callable
            .with(0).arguments
            .and_keywords(:repository, :request, :resource)
            .and_any_keywords
        end
      end

      describe '#command_class' do
        let(:configured_command_class) do
          expected = command_class
          expected = instance_exec(&expected) if expected.is_a?(Proc)
          expected = Object.const_get(expected) if expected.is_a?(String)
          expected
        end

        it { expect(action.command_class).to be configured_command_class }
      end
    end

    deferred_examples 'should delegate to the command' do
      let(:expected_params) do
        next super() if defined?(super())

        params.symbolize_keys
      end
      let(:expected_result) do
        next super() if defined?(super())

        Cuprum::Result.new
      end
      let(:expected_value) do
        next super() if defined?(super())

        nil
      end
      let(:mock_command) do
        instance_double(subject.command_class, call: expected_result)
      end

      before(:example) do
        allow(subject.command_class).to receive(:new).and_return(mock_command)
      end

      it 'should return a passing result with the response value' do
        expect(call_action)
          .to be_a_passing_result
          .with_value(match(expected_value))
      end

      it 'should initialize the command' do
        call_action

        expect(subject.command_class)
          .to have_received(:new)
          .with(repository:, resource:)
      end

      it 'should call the command' do # rubocop:disable RSpec/ExampleLength
        call_action

        have_received_call = have_received(:call)
        have_received_call =
          if expected_params.empty?
            have_received_call.with(no_args)
          else
            have_received_call.with(**expected_params)
          end

        expect(mock_command).to have_received_call
      end
    end

    deferred_examples 'should require a command' do
      let(:expected_error) do
        Cuprum::Errors::CommandNotImplemented.new(command: action)
      end

      it 'should return a failing result with a CommandNotImplented error' do
        expect(call_action)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    deferred_examples 'should validate the parameters' \
    do |using_contract:, invalid_params: {}, validation_error: nil|
      describe 'with invalid parameters' do
        let(:configured_error) do
          error = validation_error
          error = instance_exec(&error) if error.is_a?(Proc)
          error
        end
        let(:configured_errors) do
          contract = using_contract
          contract = instance_exec(&contract) if contract.is_a?(Proc)
          contract.errors_for(configured_params)
        end
        let(:configured_params) do
          params = invalid_params
          params = instance_exec(&params) if params.is_a?(Proc)
          params
        end
        let(:request) do
          instance_double(Cuprum::Rails::Request, params: configured_params)
        end
        let(:expected_error) do
          next super() if defined?(super())

          next configured_error if configured_error

          Cuprum::Rails::Errors::InvalidParameters
            .new(errors: configured_errors)
        end

        it 'should return a failing result' do
          expect(call_action)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end
    end
  end
end
