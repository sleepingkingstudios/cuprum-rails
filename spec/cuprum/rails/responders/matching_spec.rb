# frozen_string_literal: true

require 'cuprum/rails/responders/matching'

RSpec.describe Cuprum::Rails::Responders::Matching do
  subject(:responder) { described_class.new(**constructor_options) }

  let(:described_class) { Spec::Responder }
  let(:action_name)     { :published }
  let(:resource)        { Cuprum::Rails::Resource.new(resource_name: 'books') }
  let(:constructor_options) do
    {
      action_name: action_name,
      resource:    resource
    }
  end

  example_class 'Spec::Responder' do |klass|
    klass.include Cuprum::Rails::Responders::Matching # rubocop:disable RSpec/DescribedClass

    klass.define_method(:render) { |str| str }
  end

  describe '.match' do
    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:match)
        .with(1).argument
        .and_keywords(:error, :value)
        .and_a_block
    end

    describe 'with status: nil' do
      let(:error_message) { "status can't be blank" }

      it 'should raise an exception' do
        expect { described_class.match(nil) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with status: an Object' do
      let(:error_message) { 'status must be a Symbol' }

      it 'should raise an exception' do
        expect { described_class.match(Object.new.freeze) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with status: an empty Symbol' do
      let(:error_message) { "status can't be blank" }

      it 'should raise an exception' do
        expect { described_class.match(:'') }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with status: a value and error: an Object' do
      let(:error_message) { 'error must be a Class or Module' }

      it 'should raise an exception' do
        expect { described_class.match(:failure, error: Object.new.freeze) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with status: a value and value: an Object' do
      let(:error_message) { 'value must be a Class or Module' }

      it 'should raise an exception' do
        expect { described_class.match(:failure, value: Object.new.freeze) }
          .to raise_error ArgumentError, error_message
      end
    end
  end

  describe '.matchers' do
    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:matchers)
        .with(0).arguments
        .and_any_keywords
    end

    it { expect(described_class.matchers).to be == [] }

    context 'when the responder defines matches' do
      let(:expected) { [described_class.send(:matcher)] }

      before(:example) do
        Spec::Responder.match(:success)
      end

      it { expect(described_class.matchers).to be == expected }
    end
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:action_name, :matcher, :member_action, :resource)
    end
  end

  describe '#action_name' do
    include_examples 'should define reader',
      :action_name,
      -> { be == action_name }
  end

  describe '#call' do
    shared_examples 'should set the matcher context' do |message|
      it 'should set the matcher context' do
        allow(responder).to receive(:render)

        responder.call(result)

        expect(responder).to have_received(:render).with(message)
      end
    end

    it { expect(responder).to respond_to(:call).with(1).argument }

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

      it 'should set the result' do
        responder.call(result)
      rescue Cuprum::Matching::NoMatchError
        expect(responder.result).to be result
      end

      it 'should raise an exception' do
        expect { responder.call(result) }
          .to raise_error Cuprum::Matching::NoMatchError, error_message
      end
    end

    context 'when initialized with matcher: a matcher' do
      let(:matcher) do
        Cuprum::Matcher.new do
          match(:failure) { render('matcher: failure') }
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

        include_examples 'should set the matcher context', 'matcher: failure'
      end
    end

    context 'when the responder defines matches' do
      before(:example) do
        Spec::Responder.match(:failure, error: Spec::CustomError) do
          render('responder: failure with error')
        end

        Spec::Responder.match(:failure) { render('responder: failure') }
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

        include_examples 'should set the matcher context', 'responder: failure'
      end

      context 'when initialized with matcher: a matcher' do
        let(:matcher) do
          Cuprum::Matcher.new do
            match(:failure) { render('matcher: failure') }
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

        describe 'with a result matching the matcher' do
          let(:result) { Cuprum::Result.new(status: :failure) }

          it { expect(responder.call(result)).to be == 'matcher: failure' }

          include_examples 'should set the matcher context', 'matcher: failure'
        end

        describe 'with a result matching the responder' do
          let(:error)  { Spec::CustomError.new }
          let(:result) { Cuprum::Result.new(status: :failure, error: error) }

          it 'should match the responder' do
            expect(responder.call(result))
              .to be == 'responder: failure with error'
          end

          include_examples 'should set the matcher context',
            'responder: failure with error'
        end
      end
    end

    context 'with a responder subclass' do
      let(:described_class) { Spec::CustomResponder }

      before(:example) do
        Spec::Responder.match(
          :failure,
          error: Spec::CustomError,
          value: Spec::RocketPart
        ) do
          render('responder: failure with value and error')
        end

        Spec::Responder.match(:failure, error: Spec::CustomError) do
          # :nocov:
          render('responder: failure with error')
          # :nocov:
        end

        Spec::Responder.match(:failure) { render('responder: failure') }

        Spec::CustomResponder.match(:failure, error: Spec::CustomError) do
          render('subclass: failure with error')
        end

        Spec::CustomResponder.match(:failure) { render('subclass: failure') }
      end

      example_class 'Spec::CustomError', Cuprum::Error

      example_class 'Spec::RocketPart'

      example_class 'Spec::CustomResponder', 'Spec::Responder'

      describe 'with a non-matching result' do
        let(:result)        { Cuprum::Result.new(status: :success) }
        let(:error_message) { "no match found for #{result.inspect}" }

        it 'should raise an exception' do
          expect { responder.call(result) }
            .to raise_error Cuprum::Matching::NoMatchError, error_message
        end
      end

      describe 'with a result matching the subclass' do
        let(:error)  { Spec::CustomError.new }
        let(:result) { Cuprum::Result.new(status: :failure, error: error) }

        it 'should match the responder subclass' do
          expect(responder.call(result)).to be == 'subclass: failure with error'
        end

        include_examples 'should set the matcher context',
          'subclass: failure with error'
      end

      describe 'with a result matching the parent class' do
        let(:error) { Spec::CustomError.new }
        let(:value) { Spec::RocketPart.new }
        let(:result) do
          Cuprum::Result.new(status: :failure, error: error, value: value)
        end

        it 'should match the responder parent class' do
          expect(responder.call(result))
            .to be == 'responder: failure with value and error'
        end

        include_examples 'should set the matcher context',
          'responder: failure with value and error'
      end

      context 'when initialized with matcher: a matcher' do
        let(:matcher) do
          Cuprum::Matcher.new do
            match(:failure) { render('matcher: failure') }
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

        describe 'with a result matching the matcher' do
          let(:result) { Cuprum::Result.new(status: :failure) }

          it { expect(responder.call(result)).to be == 'matcher: failure' }

          include_examples 'should set the matcher context', 'matcher: failure'
        end

        describe 'with a result matching the subclass' do
          let(:error)  { Spec::CustomError.new }
          let(:result) { Cuprum::Result.new(status: :failure, error: error) }

          it 'should match the responder subclass' do
            expect(responder.call(result))
              .to be == 'subclass: failure with error'
          end

          include_examples 'should set the matcher context',
            'subclass: failure with error'
        end

        describe 'with a result matching the parent class' do
          let(:error) { Spec::CustomError.new }
          let(:value) { Spec::RocketPart.new }
          let(:result) do
            Cuprum::Result.new(status: :failure, error: error, value: value)
          end

          it 'should match the responder parent class' do
            expect(responder.call(result))
              .to be == 'responder: failure with value and error'
          end

          include_examples 'should set the matcher context',
            'responder: failure with value and error'
        end
      end
    end

    context 'with an included responder module' do
      before(:example) do
        Spec::IncludedResponder.match(
          :failure,
          error: Spec::CustomError,
          value: Spec::RocketPart
        ) do
          render('included: failure with value and error')
        end

        Spec::IncludedResponder.match(:failure, error: Spec::CustomError) do
          # :nocov:
          render('included: failure with error')
          # :nocov:
        end

        Spec::IncludedResponder.match(:failure) { render('included: failure') }

        Spec::Responder.match(:failure, error: Spec::CustomError) do
          render('responder: failure with error')
        end

        Spec::Responder.match(:failure) { render('responder: failure') }

        Spec::Responder.include(Spec::IncludedResponder)
      end

      example_constant 'Spec::IncludedResponder' do
        Module.new.include Cuprum::Rails::Responders::Matching # rubocop:disable RSpec/DescribedClass
      end

      example_class 'Spec::CustomError', Cuprum::Error

      example_class 'Spec::RocketPart'

      example_class 'Spec::CustomResponder', 'Spec::Responder'

      describe 'with a non-matching result' do
        let(:result)        { Cuprum::Result.new(status: :success) }
        let(:error_message) { "no match found for #{result.inspect}" }

        it 'should raise an exception' do
          expect { responder.call(result) }
            .to raise_error Cuprum::Matching::NoMatchError, error_message
        end
      end

      describe 'with a result matching the base responder' do
        let(:error)  { Spec::CustomError.new }
        let(:result) { Cuprum::Result.new(status: :failure, error: error) }

        it 'should match the base responder' do
          expect(responder.call(result))
            .to be == 'responder: failure with error'
        end

        include_examples 'should set the matcher context',
          'responder: failure with error'
      end

      describe 'with a result matching the included responder' do
        let(:error) { Spec::CustomError.new }
        let(:value) { Spec::RocketPart.new }
        let(:result) do
          Cuprum::Result.new(status: :failure, error: error, value: value)
        end

        it 'should match the included responder' do
          expect(responder.call(result))
            .to be == 'included: failure with value and error'
        end

        include_examples 'should set the matcher context',
          'included: failure with value and error'
      end

      context 'when initialized with matcher: a matcher' do
        let(:matcher) do
          Cuprum::Matcher.new do
            match(:failure) { render('matcher: failure') }
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

        describe 'with a result matching the matcher' do
          let(:result) { Cuprum::Result.new(status: :failure) }

          it { expect(responder.call(result)).to be == 'matcher: failure' }

          include_examples 'should set the matcher context', 'matcher: failure'
        end

        describe 'with a result matching the base responder' do
          let(:error)  { Spec::CustomError.new }
          let(:result) { Cuprum::Result.new(status: :failure, error: error) }

          it 'should match the base responder' do
            expect(responder.call(result))
              .to be == 'responder: failure with error'
          end

          include_examples 'should set the matcher context',
            'responder: failure with error'
        end

        describe 'with a result matching the included responder' do
          let(:error) { Spec::CustomError.new }
          let(:value) { Spec::RocketPart.new }
          let(:result) do
            Cuprum::Result.new(status: :failure, error: error, value: value)
          end

          it 'should match the included responder' do
            expect(responder.call(result))
              .to be == 'included: failure with value and error'
          end

          include_examples 'should set the matcher context',
            'included: failure with value and error'
        end
      end
    end

    context 'with a prepended responder module' do
      before(:example) do
        Spec::Responder.match(
          :failure,
          error: Spec::CustomError,
          value: Spec::RocketPart
        ) do
          render('responder: failure with value and error')
        end

        Spec::Responder.match(:failure, error: Spec::CustomError) do
          # :nocov:
          render('responder: failure with error')
          # :nocov:
        end

        Spec::Responder.match(:failure) { render('responder: failure') }

        Spec::PrependedResponder.match(:failure, error: Spec::CustomError) do
          render('prepended: failure with error')
        end

        Spec::PrependedResponder.match(:failure) do
          # :nocov:
          render('prepended: failure')
          # :nocov:
        end

        Spec::Responder.prepend(Spec::PrependedResponder)
      end

      example_constant 'Spec::PrependedResponder' do
        Module.new.include Cuprum::Rails::Responders::Matching # rubocop:disable RSpec/DescribedClass
      end

      example_class 'Spec::CustomError', Cuprum::Error

      example_class 'Spec::RocketPart'

      example_class 'Spec::CustomResponder', 'Spec::Responder'

      describe 'with a non-matching result' do
        let(:result)        { Cuprum::Result.new(status: :success) }
        let(:error_message) { "no match found for #{result.inspect}" }

        it 'should raise an exception' do
          expect { responder.call(result) }
            .to raise_error Cuprum::Matching::NoMatchError, error_message
        end
      end

      describe 'with a result matching the prepended responder' do
        let(:error)  { Spec::CustomError.new }
        let(:result) { Cuprum::Result.new(status: :failure, error: error) }

        it 'should match the prepended responder' do
          expect(responder.call(result))
            .to be == 'prepended: failure with error'
        end

        include_examples 'should set the matcher context',
          'prepended: failure with error'
      end

      describe 'with a result matching the base responder' do
        let(:error) { Spec::CustomError.new }
        let(:value) { Spec::RocketPart.new }
        let(:result) do
          Cuprum::Result.new(status: :failure, error: error, value: value)
        end

        it 'should match the base responder' do
          expect(responder.call(result))
            .to be == 'responder: failure with value and error'
        end

        include_examples 'should set the matcher context',
          'responder: failure with value and error'
      end

      context 'when initialized with matcher: a matcher' do
        let(:matcher) do
          Cuprum::Matcher.new do
            match(:failure) { render('matcher: failure') }
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

        describe 'with a result matching the matcher' do
          let(:result) { Cuprum::Result.new(status: :failure) }

          it { expect(responder.call(result)).to be == 'matcher: failure' }

          include_examples 'should set the matcher context', 'matcher: failure'
        end

        describe 'with a result matching the prepended responder' do
          let(:error)  { Spec::CustomError.new }
          let(:result) { Cuprum::Result.new(status: :failure, error: error) }

          it 'should match the prepended responder' do
            expect(responder.call(result))
              .to be == 'prepended: failure with error'
          end

          include_examples 'should set the matcher context',
            'prepended: failure with error'
        end

        describe 'with a result matching the base responder' do
          let(:error) { Spec::CustomError.new }
          let(:value) { Spec::RocketPart.new }
          let(:result) do
            Cuprum::Result.new(status: :failure, error: error, value: value)
          end

          it 'should match the base responder' do
            expect(responder.call(result))
              .to be == 'responder: failure with value and error'
          end

          include_examples 'should set the matcher context',
            'responder: failure with value and error'
        end
      end
    end
  end

  describe '#format' do
    include_examples 'should define reader', :format, nil
  end

  describe '#matcher' do
    include_examples 'should define reader', :matcher, nil

    context 'when initialized with matcher: a matcher' do
      let(:matcher)             { Cuprum::Matcher.new }
      let(:constructor_options) { super().merge(matcher: matcher) }

      it { expect(responder.matcher).to be matcher }
    end
  end

  describe '#matchers' do
    let(:matchers) { responder.send(:matchers) }
    let(:expected) { [] }

    include_examples 'should define private reader', :matchers

    it { expect(matchers).to be == expected }

    context 'when the responder defines matches' do
      let(:expected) { super().concat([described_class.send(:matcher)]) }

      before(:example) do
        Spec::Responder.match(:failure, error: Spec::CustomError) do
          # :nocov:
          render('responder: failure with error')
          # :nocov:
        end

        Spec::Responder.match(:failure) { render('responder: failure') }
      end

      example_class 'Spec::CustomError', Cuprum::Error

      it { expect(matchers).to be == expected }
    end

    context 'when initialized with matcher: a matcher' do
      let(:matcher)             { Cuprum::Matcher.new }
      let(:constructor_options) { super().merge(matcher: matcher) }
      let(:expected)            { [matcher] }

      it { expect(matchers).to be == expected }

      context 'when the responder defines matches' do
        let(:expected) { super().concat([described_class.send(:matcher)]) }

        before(:example) do
          Spec::Responder.match(:failure, error: Spec::CustomError) do
            # :nocov:
            render('responder: failure with error')
            # :nocov:
          end

          Spec::Responder.match(:failure) { render('responder: failure') }
        end

        example_class 'Spec::CustomError', Cuprum::Error

        it { expect(matchers).to be == expected }
      end
    end

    context 'with a responder subclass' do
      let(:described_class) { Spec::CustomResponder }
      let(:expected)        { [] }

      example_class 'Spec::CustomResponder', 'Spec::Responder'

      it { expect(matchers).to be == expected }

      context 'when the responder defines matches' do
        let(:expected) do
          super().concat([Spec::CustomResponder.send(:matcher)])
        end

        before(:example) do
          Spec::CustomResponder.match(:failure) { render('responder: failure') }
        end

        it { expect(matchers).to be == expected }
      end

      context 'when the superclass defines matches' do
        let(:expected) do
          super().concat([Spec::Responder.send(:matcher)])
        end

        before(:example) do
          Spec::Responder.match(:failure) { render('responder: failure') }
        end

        it { expect(matchers).to be == expected }
      end

      context 'when the responder and superclass define matchers' do
        let(:expected) do
          super().concat(
            [
              Spec::CustomResponder.send(:matcher),
              Spec::Responder.send(:matcher)
            ]
          )
        end

        before(:example) do
          Spec::CustomResponder.match(:failure) { render('responder: failure') }

          Spec::Responder.match(:failure) { render('responder: failure') }
        end

        it { expect(matchers).to be == expected }
      end

      context 'when initialized with matcher: a matcher' do
        let(:matcher)             { Cuprum::Matcher.new }
        let(:constructor_options) { super().merge(matcher: matcher) }
        let(:expected)            { [matcher] }

        it { expect(matchers).to be == expected }

        context 'when the responder and superclass define matchers' do
          let(:expected) do
            super().concat(
              [
                Spec::CustomResponder.send(:matcher),
                Spec::Responder.send(:matcher)
              ]
            )
          end

          before(:example) do
            Spec::CustomResponder.match(:failure) do
              # :nocov:
              render('responder: failure')
              # :nocov:
            end

            Spec::Responder.match(:failure) { render('responder: failure') }
          end

          it { expect(matchers).to be == expected }
        end
      end
    end
  end

  describe '#matcher_options' do
    include_examples 'should define private reader', :matcher_options, -> { {} }
  end

  describe '#member_action?' do
    include_examples 'should define predicate', :member_action?, false

    context 'when initialized with member_action: true' do
      let(:constructor_options) { super().merge(member_action: true) }

      it { expect(responder.member_action?).to be true }
    end
  end

  describe '#resource' do
    include_examples 'should define reader', :resource, -> { resource }
  end

  describe '#result' do
    include_examples 'should define reader', :result, nil
  end
end
