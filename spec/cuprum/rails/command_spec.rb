# frozen_string_literal: true

require 'cuprum/rails/command'

RSpec.describe Cuprum::Rails::Command do
  subject(:command) do
    described_class.new(**constructor_options, &implementation)
  end

  deferred_context 'when initialized with an implementation block' do
    let(:implementation) do
      ->(**params) { params.merge(ok: true) }
    end
  end

  deferred_context 'when initialized with repository: value' do
    let(:repository)          { Cuprum::Collections::Repository.new }
    let(:constructor_options) { super().merge(repository:) }
  end

  deferred_context 'when initialized with resource: value' do
    let(:resource)            { Cuprum::Rails::Resource.new(name: 'books') }
    let(:constructor_options) { super().merge(resource:) }
  end

  let(:options)             { {} }
  let(:implementation)      { nil }
  let(:constructor_options) { options }

  describe '.subclass' do
    it 'should define the class method' do
      expect(described_class).to respond_to(:subclass)
    end
  end

  describe '.new' do
    it 'should define the constructor' do # rubocop:disable RSpec/ExampleLength
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:repository, :resource)
        .and_any_keywords
        .and_a_block
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

    wrap_deferred 'when initialized with an implementation block' do
      let(:expected_value) { { ok: true } }

      it 'should return a passing result' do
        expect(command.call)
          .to be_a_passing_result
          .with_value(expected_value)
      end

      describe 'with keywords' do
        let(:keywords)       { { key: 'value' } }
        let(:expected_value) { keywords.merge(super()) }

        it 'should return a passing result' do
          expect(command.call(**keywords))
            .to be_a_passing_result
            .with_value(expected_value)
        end
      end
    end

    context 'with a command subclass that raises an exception' do
      let(:described_class) { Spec::CustomCommand }
      let(:expected_error) do
        Cuprum::Errors::UncaughtException.new(
          exception: StandardError.new('Something went wrong'),
          message:   "uncaught exception in #{described_class.name} - "
        )
      end

      example_class 'Spec::CustomCommand', Cuprum::Rails::Command do |klass| # rubocop:disable RSpec/DescribedClass
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

      example_class 'Spec::CustomCommand', Cuprum::Rails::Command do |klass| # rubocop:disable RSpec/DescribedClass
        klass.validate :name, :presence

        klass.define_method(:process) do |name = nil|
          # :nocov:
          "Greetings, #{name}"
          # :nocov:
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

    wrap_deferred 'when initialized with repository: value' do # rubocop:disable RSpec/RepeatedExampleGroupBody
      it { expect(command.options).to be == options }
    end

    wrap_deferred 'when initialized with resource: value' do # rubocop:disable RSpec/RepeatedExampleGroupBody
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
