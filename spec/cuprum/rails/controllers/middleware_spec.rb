# frozen_string_literal: true

require 'cuprum/middleware'

require 'cuprum/rails/controllers/middleware'

RSpec.describe Cuprum::Rails::Controllers::Middleware do
  subject(:middleware) { described_class.new(**constructor_options) }

  let(:command) { Cuprum::Command.new }
  let(:constructor_options) do
    { command: command }
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:command, :except, :only)
    end
  end

  describe '#command' do
    include_examples 'should define reader', :command, -> { command }
  end

  describe '#except' do
    include_examples 'should define reader', :except, Set.new([])

    context 'when initialized with except: an array of strings' do
      let(:excepted_actions)    { %w[index show] }
      let(:constructor_options) { super().merge(except: excepted_actions) }
      let(:expected)            { Set.new(excepted_actions.map(&:intern)) }

      it { expect(middleware.except).to be == expected }
    end

    context 'when initialized with except: an array of symbols' do
      let(:excepted_actions)    { %i[index show] }
      let(:constructor_options) { super().merge(except: excepted_actions) }
      let(:expected)            { Set.new(excepted_actions) }

      it { expect(middleware.except).to be == expected }
    end
  end

  describe '#matches?' do
    it { expect(middleware).to respond_to(:matches?).with(1).argument }

    it 'should alias the method as #match?' do
      expect(middleware.method(:matches?)).to be == middleware.method(:match?)
    end

    describe 'with an action name' do
      let(:action_name) { :index }

      it { expect(middleware.matches? action_name).to be true }
    end

    context 'when initialized with except: an array of symbols' do
      let(:excepted_actions)    { %i[index show] }
      let(:constructor_options) { super().merge(except: excepted_actions) }

      describe 'with an invalid action name' do
        let(:action_name) { :show }

        it { expect(middleware.matches? action_name).to be false }
      end

      describe 'with a valid action name' do
        let(:action_name) { :destroy }

        it { expect(middleware.matches? action_name).to be true }
      end
    end

    context 'when initialized with only: an array of symbols' do
      let(:only_actions)        { %i[create update] }
      let(:constructor_options) { super().merge(only: only_actions) }

      describe 'with an invalid action name' do
        let(:action_name) { :edit }

        it { expect(middleware.matches? action_name).to be false }
      end

      describe 'with a valid action name' do
        let(:action_name) { :create }

        it { expect(middleware.matches? action_name).to be true }
      end
    end
  end

  describe '#only' do
    include_examples 'should define reader', :only, Set.new([])

    context 'when initialized with only: an array of strings' do
      let(:only_actions)        { %w[create update] }
      let(:constructor_options) { super().merge(only: only_actions) }
      let(:expected)            { Set.new(only_actions.map(&:intern)) }

      it { expect(middleware.only).to be == expected }
    end

    context 'when initialized with only: an array of symbols' do
      let(:only_actions)        { %i[create update] }
      let(:constructor_options) { super().merge(only: only_actions) }
      let(:expected)            { Set.new(only_actions) }

      it { expect(middleware.only).to be == expected }
    end
  end
end
