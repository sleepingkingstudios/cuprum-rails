# frozen_string_literal: true

require 'cuprum/middleware'

require 'cuprum/rails/controllers/middleware'

RSpec.describe Cuprum::Rails::Controllers::Middleware do
  subject(:middleware) { described_class.new(**constructor_options) }

  let(:command) { Cuprum::Command.new }
  let(:constructor_options) do
    { command: }
  end

  describe '::InclusionMatcher' do
    subject(:matcher) { described_class.new(except:, only:) }

    let(:described_class) { super()::InclusionMatcher }
    let(:except)          { [] }
    let(:only)            { [] }

    describe '.build' do
      let(:value)   { Object.new.freeze }
      let(:matcher) { described_class.build(value) }

      it { expect(described_class).to respond_to(:build).with(1).argument }

      it { expect(matcher).to be_a described_class }

      describe 'with nil' do
        let(:value) { nil }

        it { expect(matcher.except).to be == Set.new }

        it { expect(matcher.only).to be == Set.new }
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        it { expect(matcher.except).to be == Set.new }

        it { expect(matcher.only).to be == Set.new([value.to_s]) }
      end

      describe 'with an empty Array' do
        let(:value) { [] }

        it { expect(matcher.except).to be == Set.new }

        it { expect(matcher.only).to be == Set.new }
      end

      describe 'with a Array of Strings' do
        let(:value) { %w[index show] }

        it { expect(matcher.except).to be == Set.new }

        it { expect(matcher.only).to be == Set.new(value) }
      end

      describe 'with a Array of Symbols' do
        let(:value) { %i[index show] }

        it { expect(matcher.except).to be == Set.new }

        it { expect(matcher.only).to be == Set.new(value.map(&:to_s)) }
      end

      describe 'with an empty Hash' do
        let(:value) { {} }

        it { expect(matcher.except).to be == Set.new }

        it { expect(matcher.only).to be == Set.new }
      end

      describe 'with an invalid Hash' do
        let(:value) { { other: 'value' } }

        it 'should raise an exception' do
          expect { described_class.build(value) }.to raise_error ArgumentError
        end
      end

      describe 'with a Hash with except: value' do
        let(:value) { { except: %w[create destroy] } }

        it { expect(matcher.except).to be == Set.new(value[:except]) }

        it { expect(matcher.only).to be == Set.new }
      end

      describe 'with a Hash with only: value' do
        let(:value) { { only: %i[index show] } }

        it { expect(matcher.except).to be == Set.new }

        it { expect(matcher.only).to be == Set.new(value[:only].map(&:to_s)) }
      end

      describe 'with a Hash with except: value and option: value' do
        let(:value) { { except: %w[create destroy], only: %w[create destroy] } }

        it { expect(matcher.except).to be == Set.new(value[:except]) }

        it { expect(matcher.only).to be == Set.new(value[:only].map(&:to_s)) }
      end
    end

    describe '.new' do
      it 'should define the constructor' do
        expect(described_class)
          .to respond_to(:new)
          .with(0).arguments
          .and_keywords(:except, :only)
      end
    end

    describe '#except' do
      include_examples 'should define reader', :except, Set.new([])

      context 'when initialized with except: an array of strings' do
        let(:except)   { %w[index show] }
        let(:expected) { Set.new(except) }

        it { expect(matcher.except).to be == expected }
      end

      context 'when initialized with except: an array of symbols' do
        let(:except)   { %i[index show] }
        let(:expected) { Set.new(except.map(&:to_s)) }

        it { expect(matcher.except).to be == expected }
      end
    end

    describe '#matches?' do
      it { expect(matcher).to respond_to(:matches?).with(1).argument }

      it { expect(matcher).to have_aliased_method(:matches?).as(:match?) }

      describe 'with a value' do
        it { expect(matcher.matches?(:index)).to be true }
      end

      context 'when initialized with except: a non-empty array' do
        let(:except) { %i[index show] }

        describe 'with an invalid value' do
          it { expect(matcher.matches?(:show)).to be false }
        end

        describe 'with a valid value' do
          it { expect(matcher.matches?(:destroy)).to be true }
        end
      end

      context 'when initialized with only: a non-empty array' do
        let(:except) { %i[create destroy] }

        describe 'with an invalid value' do
          it { expect(matcher.matches?(:show)).to be true }
        end

        describe 'with a valid value' do
          it { expect(matcher.matches?(:destroy)).to be false }
        end
      end

      context 'when initialized with both except: and only: values' do
        let(:except) { %i[new create edit update] }
        let(:only)   { %i[index new create show] }

        describe 'with a value that is neither included nor excluded' do
          it { expect(matcher.matches?(:destroy)).to be false }
        end

        describe 'with a value that is excluded' do
          it { expect(matcher.matches?(:update)).to be false }
        end

        describe 'with a value that is included' do
          it { expect(matcher.matches?(:index)).to be true }
        end

        describe 'with a value that is both included and excluded' do
          it { expect(matcher.matches?(:create)).to be false }
        end
      end
    end

    describe '#only' do
      include_examples 'should define reader', :only, Set.new([])

      context 'when initialized with only: an array of strings' do
        let(:only)     { %w[create update] }
        let(:expected) { Set.new(only) }

        it { expect(matcher.only).to be == expected }
      end

      context 'when initialized with only: an array of symbols' do
        let(:only)     { %i[create update] }
        let(:expected) { Set.new(only.map(&:to_s)) }

        it { expect(matcher.only).to be == expected }
      end
    end
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:command, :actions, :formats)
    end
  end

  describe '#==' do
    describe 'with nil' do
      it { expect(middleware == nil).to be false } # rubocop:disable Style/NilComparison
    end

    describe 'with an object' do
      it { expect(middleware == Object.new.freeze).to be false }
    end

    describe 'with middleware with a different command' do
      let(:other) { described_class.new(command: Cuprum::Command.new) }

      it { expect(middleware == other).to be false }
    end

    describe 'with middleware with the same command' do
      let(:options) { {} }
      let(:other)   { described_class.new(command:, **options) }

      it { expect(middleware == other).to be true }

      describe 'with non-matching actions' do
        let(:other_actions) do
          described_class::InclusionMatcher.build({ except: %i[drafts] })
        end
        let(:options) { super().merge(actions: other_actions) }

        it { expect(middleware == other).to be false }
      end

      describe 'with non-matching formats' do
        let(:other_formats) do
          described_class::InclusionMatcher.build({ except: %i[soap] })
        end
        let(:options) { super().merge(formats: other_formats) }

        it { expect(middleware == other).to be false }
      end
    end

    context 'when initialized with actions' do
      let(:actions) do
        described_class::InclusionMatcher.build({
          except: %i[create destroy update],
          only:   %i[index show create]
        })
      end
      let(:constructor_options) { super().merge(actions:) }

      describe 'with middleware with a different command' do
        let(:other) { described_class.new(command: Cuprum::Command.new) }

        it { expect(middleware == other).to be false }
      end

      describe 'with middleware with the same command' do
        let(:options) { {} }
        let(:other)   { described_class.new(command:, **options) }

        it { expect(middleware == other).to be false }

        describe 'with non-matching actions' do
          let(:other_actions) do
            described_class::InclusionMatcher.build({ except: %i[drafts] })
          end
          let(:options) { super().merge(actions: other_actions) }

          it { expect(middleware == other).to be false }
        end

        describe 'with matching actions' do
          let(:options) { super().merge(actions:) }

          it { expect(middleware == other).to be true }
        end
      end
    end
  end

  describe '#actions' do
    include_examples 'should define reader', :actions, nil

    context 'when initialized with actions' do
      let(:actions) do
        described_class::InclusionMatcher.build({
          except: %i[create destroy update],
          only:   %i[index show create]
        })
      end
      let(:constructor_options) { super().merge(actions:) }

      it { expect(middleware.actions).to be == actions }
    end
  end

  describe '#command' do
    include_examples 'should define reader', :command, -> { command }
  end

  describe '#formats' do
    include_examples 'should define reader', :formats, nil

    context 'when initialized with formats' do
      let(:formats) do
        described_class::InclusionMatcher.build({
          except: %i[json xml],
          only:   %i[html xml turbo_stream]
        })
      end
      let(:constructor_options) { super().merge(formats:) }

      it { expect(middleware.formats).to be == formats }
    end
  end

  describe '#matches?' do
    let(:action_name)     { :index }
    let(:format)          { :json }
    let(:request_options) { { action_name:, format: } }
    let(:request) do
      Cuprum::Rails::Request.new(**request_options)
    end

    it { expect(middleware).to respond_to(:matches?).with(1).argument }

    it 'should alias the method as #match?' do
      expect(middleware.method(:matches?)).to be == middleware.method(:match?)
    end

    it { expect(middleware.matches?(request)).to be true }

    context 'when initialized with actions' do
      let(:actions) do
        described_class::InclusionMatcher.build({
          except: %i[create destroy update],
          only:   %i[index show create]
        })
      end
      let(:constructor_options) { super().merge(actions:) }

      describe 'with an action name not in actions.except or actions.only' do
        let(:action_name) { :new }

        it { expect(middleware.matches?(request)).to be false }
      end

      describe 'with an action name in actions.except' do
        let(:action_name) { :destroy }

        it { expect(middleware.matches?(request)).to be false }
      end

      describe 'with an action name in actions.only' do
        let(:action_name) { :index }

        it { expect(middleware.matches?(request)).to be true }
      end

      describe 'with an action name in actions.except and actions.only' do
        let(:action_name) { :create }

        it { expect(middleware.matches?(request)).to be false }
      end
    end

    context 'when initialized with formats' do
      let(:formats) do
        described_class::InclusionMatcher.build({
          except: %i[json xml],
          only:   %i[html xml turbo_stream]
        })
      end
      let(:constructor_options) { super().merge(formats:) }

      describe 'with a format not in formats.except or formats.only' do
        let(:format) { :xhtml }

        it { expect(middleware.matches?(request)).to be false }
      end

      describe 'with a format in formats.except' do
        let(:format) { :json }

        it { expect(middleware.matches?(request)).to be false }
      end

      describe 'with a format in formats.only' do
        let(:format) { :html }

        it { expect(middleware.matches?(request)).to be true }
      end

      describe 'with a format in formats.except and formats.only' do
        let(:format) { :xml }

        it { expect(middleware.matches?(request)).to be false }
      end
    end

    context 'when initialized with multiple options' do
      let(:actions) do
        described_class::InclusionMatcher.build({
          except: %i[create destroy update],
          only:   %i[index show create]
        })
      end
      let(:formats) do
        described_class::InclusionMatcher.build({
          except: %i[json xml],
          only:   %i[html xml turbo_stream]
        })
      end
      let(:constructor_options) { super().merge(actions:, formats:) }

      describe 'with a request matching none of the options' do
        let(:action_name) { :destroy }
        let(:format)      { :json }

        it { expect(middleware.matches?(request)).to be false }
      end

      describe 'with a request matching some of the options' do
        let(:action_name) { :index }

        it { expect(middleware.matches?(request)).to be false }
      end

      describe 'with a request matching all of the options' do
        let(:action_name) { :index }
        let(:format)      { :html }

        it { expect(middleware.matches?(request)).to be true }
      end
    end
  end
end
