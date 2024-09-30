# frozen_string_literal: true

require 'support/examples/actions'

module Spec::Support::Examples::Actions
  module ResourceActionExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_context 'when initialized with a command class' do
      example_class 'Spec::CustomCommand', Cuprum::Rails::Command

      let(:options) { super().merge(command_class: Spec::CustomCommand) }
    end

    deferred_examples 'should implement the resource action methods' do
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
        include_examples 'should define private reader',
          :command_class,
          Cuprum::Rails::Commands::Resources::Index

        wrap_deferred 'when initialized with a command class' do
          it { expect(action.send(:command_class)).to be Spec::CustomCommand }
        end
      end
    end

    deferred_examples 'should wrap the command' do |command_class:|
      let(:params) { defined?(super()) ? super() : {} }
      let(:repository) do
        next super() if defined?(super())

        Cuprum::Collections::Basic::Repository.new
      end
      let(:resource) do
        next super() if defined?(super())

        Cuprum::Rails::Resource.new(name: 'books')
      end
      let(:request) do
        next super() if defined?(super())

        instance_double(Cuprum::Rails::Request, params:)
      end
      let(:expected_command_class) do
        next command_class if command_class.is_a?(Class)

        # :nocov:
        Object.const_get(command_class)
        # :nocov:
      end
      let(:expected_result) do
        defined?(super()) ? super() : Cuprum::Result.new
      end
      let(:expected_value) do
        defined?(super()) ? super() : expected_result.value
      end
      let(:expected_parameters) do
        defined?(super()) ? super() : {}
      end
      let(:mock_command) do
        instance_double(Cuprum::Command, call: expected_result)
      end

      before(:example) do
        allow(expected_command_class).to receive(:new).and_return(mock_command)
      end

      def call_action
        action.call(repository:, request:, resource:)
      end

      it 'should initialize the command' do
        call_action

        expect(expected_command_class)
          .to have_received(:new)
          .with(repository:, resource:)
      end

      it 'should call the command' do # rubocop:disable RSpec/ExampleLength
        call_action

        matcher = have_received(:call)

        # :nocov:
        matcher =
          if expected_parameters.empty?
            matcher.with(no_args)
          else
            matcher.with(**expected_parameters)
          end
        # :nocov:

        expect(mock_command).to matcher
      end

      it 'should return a passing result' do
        expect(call_action)
          .to be_a_passing_result
          .with_value(expected_value)
      end

      context 'when the command returns a failing result' do
        let(:expected_error) do
          next super() if defined?(super())

          Cuprum::Error.new(message: 'Something went wrong')
        end
        let(:expected_result) { Cuprum::Result.new(error: expected_error) }

        it 'should return a failing result' do
          expect(call_action)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      wrap_deferred 'when initialized with a command class' do
        let(:expected_command_class) { Spec::CustomCommand }

        it 'should initialize the command' do
          call_action

          expect(expected_command_class)
            .to have_received(:new)
            .with(repository:, resource:)
        end
      end
    end
  end
end
