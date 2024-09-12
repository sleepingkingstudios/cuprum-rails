# frozen_string_literal: true

require 'cuprum/rails/command'

RSpec.describe Cuprum::Rails::Command do
  subject(:command) { described_class.new(**constructor_options) }

  deferred_context 'when initialized with repository: value' do
    let(:repository)          { Cuprum::Collections::Repository.new }
    let(:constructor_options) { super().merge(repository:) }
  end

  deferred_context 'when initialized with resource: value' do
    let(:resource)            { Cuprum::Rails::Resource.new(name: 'books') }
    let(:constructor_options) { super().merge(resource:) }
  end

  let(:options)             { {} }
  let(:constructor_options) { options }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:repository, :resource)
        .and_any_keywords
    end
  end

  describe '#call' do
    let(:expected_error) do
      Cuprum::Errors::CommandNotImplemented.new(command:)
    end

    it { expect(command).to be_callable.with(0).arguments }

    it 'should return a failing result' do
      expect(command.call)
        .to be_a_failing_result
        .with_error(expected_error)
    end

    context 'with a command subclass that raises an exception' do
      let(:described_class) { Spec::CustomCommand }
      let(:expected_error) do
        Cuprum::Errors::UncaughtException.new(
          exception: StandardError.new('Something went wrong'),
          message:   "uncaught exception in #{described_class.name} - "
        )
      end

      example_class 'Spec::CustomCommand', Cuprum::Rails::Command do |klass|
        klass.define_method(:process) do
          raise StandardError, 'Something went wrong'
        end
      end

      it 'should return a failing result' do
        expect(command.call)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    context 'with a command subclass that validates the parameters' do
      let(:described_class) { Spec::CustomCommand }
      let(:expected_error) do
        failure_message = tools.assertions.error_message_for(
          'sleeping_king_studios.tools.assertions.presence',
          as: 'name'
        )

        Cuprum::Errors::InvalidParameters.new(
          command_class: described_class,
          failures:      [failure_message]
        )
      end

      def tools
        SleepingKingStudios::Tools::Toolbelt.instance
      end

      example_class 'Spec::CustomCommand', Cuprum::Rails::Command do |klass|
        klass.validate :name, :presence

        klass.define_method(:process) do |name = nil|
          "Greetings, #{name}"
        end
      end

      it 'should return a failing result' do
        expect(command.call)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end
  end

  describe '#options' do
    include_examples 'should define reader', :options, -> { {} }

    context 'when initialized with options' do
      let(:options) { super().merge(option: 'value') }

      it { expect(command.options).to be == options }
    end

    wrap_deferred 'when initialized with repository: value' do
      it { expect(command.options).to be == options }
    end

    wrap_deferred 'when initialized with resource: value' do
      it { expect(command.options).to be == options }
    end
  end

  describe '#repository' do
    include_examples 'should define reader', :repository, nil

    wrap_deferred 'when initialized with repository: value' do
      it { expect(command.repository).to be repository }
    end
  end

  describe '#resource' do
    include_examples 'should define reader', :resource, nil

    wrap_deferred 'when initialized with resource: value' do
      it { expect(command.resource).to be resource }
    end
  end
end
