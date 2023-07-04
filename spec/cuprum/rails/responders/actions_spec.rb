# frozen_string_literal: true

require 'cuprum/rails/responders/actions'
require 'cuprum/rails/responders/base_responder'
require 'cuprum/rails/responders/matching'
require 'cuprum/rails/rspec/contracts/responder_contracts'

RSpec.describe Cuprum::Rails::Responders::Actions do
  include Cuprum::Rails::RSpec::Contracts::ResponderContracts

  subject(:responder) { described_class.new(**constructor_options) }

  let(:described_class) { Spec::ActionResponder }
  let(:action_name)     { :published }
  let(:controller)      { Spec::CustomController.new }
  let(:request)         { Cuprum::Rails::Request.new }
  let(:constructor_options) do
    {
      action_name: action_name,
      controller:  controller,
      request:     request
    }
  end

  example_class 'Spec::ActionResponder',
    Cuprum::Rails::Responders::BaseResponder \
  do |klass|
    klass.include Cuprum::Rails::Responders::Matching
    klass.include Cuprum::Rails::Responders::Actions # rubocop:disable RSpec/DescribedClass
  end

  include_contract 'should implement the responder methods',
    constructor_keywords: %i[matcher]

  describe '.action' do
    shared_examples 'should define the action matcher' do
      let(:block)   { -> {} }
      let(:matcher) { described_class.actions[action_name.intern] }

      example_constant 'Spec::MockMatcher', Struct.new(:block)

      before(:example) do
        allow(Cuprum::Matcher).to receive(:new) do |&block|
          Spec::MockMatcher.new(block)
        end
      end

      it { expect(described_class.action(action_name, &block)).to be nil }

      it 'should add the matcher to actions' do
        expect { described_class.action(action_name, &block) }
          .to change(described_class, :actions)
          .to have_key(action_name.intern)
      end

      it 'should define the action matcher' do
        described_class.action(action_name, &block)

        expect(matcher).to be_a(Spec::MockMatcher)
          .and have_attributes(block: block)
      end
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:action)
        .with(1).argument
        .and_a_block
    end

    describe 'with nil' do
      let(:error_message) { "action name can't be blank" }

      it 'should raise an exception' do
        expect { described_class.action(nil) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an Object' do
      let(:error_message) { 'action name must be a String or Symbol' }

      it 'should raise an exception' do
        expect { described_class.action(Object.new.freeze) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an empty string' do
      let(:error_message) { "action name can't be blank" }

      it 'should raise an exception' do
        expect { described_class.action('') }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an empty symbol' do
      let(:error_message) { "action name can't be blank" }

      it 'should raise an exception' do
        expect { described_class.action(:'') }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a String' do
      let(:action_name) { 'process' }

      include_examples 'should define the action matcher'
    end

    describe 'with a Symbol' do
      let(:action_name) { :process }

      include_examples 'should define the action matcher'
    end
  end

  describe '.actions' do
    include_examples 'should define class reader', :actions, -> { {} }
  end

  describe '.matchers' do
    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:matchers)
        .with(0).arguments
        .and_keywords(:action_name)
        .and_any_keywords
    end

    it { expect(described_class.matchers).to be == [] }

    context 'when the responder defines actions' do
      let(:expected) { [] }

      before(:example) do
        Spec::ActionResponder.action(:process)
      end

      describe 'with no keywords' do
        it { expect(described_class.matchers).to be == expected }
      end

      describe 'with a non-matching action name' do
        it 'should not return the action matcher' do
          expect(described_class.matchers(action_name: 'publish'))
            .to be == expected
        end
      end

      describe 'with a matching action name' do
        let(:expected) { [described_class.actions[:process], *super()] }

        it 'should return the action matcher' do
          expect(described_class.matchers(action_name: 'process'))
            .to be == expected
        end
      end
    end

    context 'when the responder defines matches' do
      let(:expected) { [described_class.send(:matcher)] }

      before(:example) do
        Spec::ActionResponder.match(:success)
      end

      it { expect(described_class.matchers).to be == expected }

      context 'when the responder defines actions' do
        before(:example) do
          Spec::ActionResponder.action(:process)
        end

        describe 'with no keywords' do
          it { expect(described_class.matchers).to be == expected }
        end

        describe 'with a non-matching action name' do
          it 'should not return the action matcher' do
            expect(described_class.matchers(action_name: 'publish'))
              .to be == expected
          end
        end

        describe 'with a matching action name' do
          let(:expected) { [described_class.actions[:process], *super()] }

          it 'should return the action matcher' do
            expect(described_class.matchers(action_name: 'process'))
              .to be == expected
          end
        end
      end
    end
  end

  describe '#call' do
    describe 'with nil' do
      let(:error_message) { 'result must be a Cuprum::Result' }

      it 'should raise an exception' do
        expect { responder.call(nil) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an Object' do
      let(:error_message) { 'result must be a Cuprum::Result' }

      it 'should raise an exception' do
        expect { responder.call(Object.new.freeze) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a result' do
      let(:result)        { Cuprum::Result.new }
      let(:error_message) { "no match found for #{result.inspect}" }

      it 'should raise an exception' do
        expect { responder.call(result) }
          .to raise_error Cuprum::Matching::NoMatchError, error_message
      end
    end

    context 'when initialized with matcher: a matcher' do
      let(:matcher) do
        Cuprum::Matcher.new do
          match(:failure) { 'matcher: failure' }
        end
      end
      let(:constructor_options) { super().merge(matcher: matcher) }

      describe 'with a non-matching result' do
        let(:result)        { Cuprum::Result.new(status: :success) }
        let(:error_message) { "no match found for #{result.inspect}" }

        it 'should raise an exception' do
          expect { responder.call(result) }
            .to raise_error Cuprum::Matching::NoMatchError, error_message
        end
      end

      describe 'with a matching result' do
        let(:result) { Cuprum::Result.new(status: :failure) }

        it { expect(responder.call(result)).to be == 'matcher: failure' }
      end
    end

    context 'when the responder defines actions' do
      before(:example) do
        Spec::ActionResponder.action(:process) do
          match(:failure) { 'action: failure' }
        end
      end

      describe 'with a non-matching action name' do
        describe 'with a non-matching result' do
          let(:result)        { Cuprum::Result.new(status: :success) }
          let(:error_message) { "no match found for #{result.inspect}" }

          it 'should raise an exception' do
            expect { responder.call(result) }
              .to raise_error Cuprum::Matching::NoMatchError, error_message
          end
        end

        describe 'with a matching result' do
          let(:result)        { Cuprum::Result.new(status: :failure) }
          let(:error_message) { "no match found for #{result.inspect}" }

          it 'should raise an exception' do
            expect { responder.call(result) }
              .to raise_error Cuprum::Matching::NoMatchError, error_message
          end
        end
      end

      describe 'with a matching action name' do
        let(:action_name) { :process }

        describe 'with a non-matching result' do
          let(:result)        { Cuprum::Result.new(status: :success) }
          let(:error_message) { "no match found for #{result.inspect}" }

          it 'should raise an exception' do
            expect { responder.call(result) }
              .to raise_error Cuprum::Matching::NoMatchError, error_message
          end
        end

        describe 'with a matching result' do
          let(:result) { Cuprum::Result.new(status: :failure) }

          it { expect(responder.call(result)).to be == 'action: failure' }
        end
      end
    end

    context 'when the responder defines matches' do
      before(:example) do
        Spec::ActionResponder.match(:failure, error: Spec::CustomError) do
          # :nocov:
          'responder: failure with error'
          # :nocov:
        end

        Spec::ActionResponder.match(:failure) { 'responder: failure' }
      end

      example_class 'Spec::CustomError', Cuprum::Error

      describe 'with a non-matching result' do
        let(:result)        { Cuprum::Result.new(status: :success) }
        let(:error_message) { "no match found for #{result.inspect}" }

        it 'should raise an exception' do
          expect { responder.call(result) }
            .to raise_error Cuprum::Matching::NoMatchError, error_message
        end
      end

      describe 'with a matching result' do
        let(:result) { Cuprum::Result.new(status: :failure) }

        it { expect(responder.call(result)).to be == 'responder: failure' }
      end
    end

    context 'with multiple matchers' do
      let(:matcher) do
        Cuprum::Matcher.new do
          match(:failure) { 'matcher: failure' }
        end
      end
      let(:constructor_options) { super().merge(matcher: matcher) }

      example_class 'Spec::CustomError', Cuprum::Error

      before(:example) do
        Spec::ActionResponder.action(:process) do
          match(:failure, error: Spec::CustomError) do
            'action: failure with error'
          end

          match(:failure) { 'action: failure' }
        end

        Spec::ActionResponder.match(:failure, error: Spec::CustomError) do
          'responder: failure with error'
        end

        Spec::ActionResponder.match(:failure) { 'responder: failure' }
      end

      describe 'with a non-matching action name' do
        describe 'with a non-matching result' do
          let(:result)        { Cuprum::Result.new(status: :success) }
          let(:error_message) { "no match found for #{result.inspect}" }

          it 'should raise an exception' do
            expect { responder.call(result) }
              .to raise_error Cuprum::Matching::NoMatchError, error_message
          end
        end

        describe 'with a generic matching result' do
          let(:result) { Cuprum::Result.new(status: :failure) }

          it { expect(responder.call(result)).to be == 'matcher: failure' }
        end

        describe 'with an exact matching result' do
          let(:error)  { Spec::CustomError.new }
          let(:result) { Cuprum::Result.new(status: :failure, error: error) }

          it 'should match the responder' do
            expect(responder.call(result))
              .to be == 'responder: failure with error'
          end
        end
      end

      describe 'with a matching action name' do
        let(:action_name) { :process }

        describe 'with a non-matching result' do
          let(:result)        { Cuprum::Result.new(status: :success) }
          let(:error_message) { "no match found for #{result.inspect}" }

          it 'should raise an exception' do
            expect { responder.call(result) }
              .to raise_error Cuprum::Matching::NoMatchError, error_message
          end
        end

        describe 'with a generic matching result' do
          let(:result) { Cuprum::Result.new(status: :failure) }

          it { expect(responder.call(result)).to be == 'matcher: failure' }
        end

        describe 'with an exact matching result' do
          let(:error)  { Spec::CustomError.new }
          let(:result) { Cuprum::Result.new(status: :failure, error: error) }

          it 'should match the responder' do
            expect(responder.call(result)).to be == 'action: failure with error'
          end
        end
      end
    end

    describe 'with a responder subclass' do
      let(:described_class) { Spec::CustomResponder }

      before(:example) do
        Spec::CustomResponder.action(:process) do
          match(:failure) { 'subclass action: failure' }
        end

        Spec::ActionResponder.action(:process) do
          match(:failure, error: Spec::CustomError) do
            'action: failure with error'
          end

          match(:failure) { 'action: failure' }
        end
      end

      example_class 'Spec::CustomError', Cuprum::Error

      example_class 'Spec::CustomResponder', 'Spec::ActionResponder'

      describe 'with a non-matching action name' do
        describe 'with a non-matching result' do
          let(:result)        { Cuprum::Result.new(status: :success) }
          let(:error_message) { "no match found for #{result.inspect}" }

          it 'should raise an exception' do
            expect { responder.call(result) }
              .to raise_error Cuprum::Matching::NoMatchError, error_message
          end
        end

        describe 'with a matching result' do
          let(:result)        { Cuprum::Result.new(status: :failure) }
          let(:error_message) { "no match found for #{result.inspect}" }

          it 'should raise an exception' do
            expect { responder.call(result) }
              .to raise_error Cuprum::Matching::NoMatchError, error_message
          end
        end
      end

      describe 'with a matching action name' do
        let(:action_name) { :process }

        describe 'with a non-matching result' do
          let(:result)        { Cuprum::Result.new(status: :success) }
          let(:error_message) { "no match found for #{result.inspect}" }

          it 'should raise an exception' do
            expect { responder.call(result) }
              .to raise_error Cuprum::Matching::NoMatchError, error_message
          end
        end

        describe 'with a generic matching result' do
          let(:result) { Cuprum::Result.new(status: :failure) }

          it 'should match the responder subclass' do
            expect(responder.call(result)).to be == 'subclass action: failure'
          end
        end

        describe 'with an exact matching result' do
          let(:error)  { Spec::CustomError.new }
          let(:result) { Cuprum::Result.new(status: :failure, error: error) }

          it 'should match the responder' do
            expect(responder.call(result)).to be == 'action: failure with error'
          end
        end
      end
    end
  end

  describe '#matcher_options' do
    include_examples 'should define private reader',
      :matcher_options,
      -> { { action_name: action_name } }
  end
end
