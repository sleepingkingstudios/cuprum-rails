# frozen_string_literal: true

require 'cuprum/rails/commands/permit_attributes'
require 'cuprum/rails/errors/resource_error'
require 'cuprum/rails/resource'

RSpec.describe Cuprum::Rails::Commands::PermitAttributes do
  subject(:command) { described_class.new(resource:, **options) }

  let(:permitted_attributes) do
    %w[title author]
  end
  let(:resource) do
    Cuprum::Rails::Resource.new(name: 'books', permitted_attributes:)
  end
  let(:options) { {} }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:resource, :require_permitted_attributes)
    end
  end

  describe '#call' do
    deferred_examples 'should filter the attributes' do
      describe 'with an empty hash' do
        let(:attributes) { {} }

        it 'should return a passing result with the attributes' do
          expect(command.call(attributes:))
            .to be_a_passing_result
            .with_value(expected_value)
        end
      end

      describe 'with a hash with string keys' do
        let(:attributes) do
          tools.hsh.convert_keys_to_strings(super())
        end
        let(:expected_value) do
          tools.hsh.convert_keys_to_strings(super())
        end

        it 'should return a passing result with the attributes' do
          expect(command.call(attributes:))
            .to be_a_passing_result
            .with_value(expected_value)
        end
      end

      describe 'with a hash with symbol keys' do
        let(:attributes) do
          tools.hsh.convert_keys_to_symbols(super())
        end
        let(:expected_value) do
          tools.hsh.convert_keys_to_strings(super())
        end

        it 'should return a passing result with the attributes' do
          expect(command.call(attributes:))
            .to be_a_passing_result
            .with_value(expected_value)
        end
      end
    end

    let(:attributes) do
      {
        title:  'Gideon the Ninth',
        author: 'Tamsyn Muir',
        rating: '5 stars'
      }
    end
    let(:expected_value) do
      tools.hsh.convert_keys_to_strings(attributes)
    end

    define_method :tools do
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    it 'should define the method' do
      expect(command)
        .to be_callable
        .with(0).arguments
        .and_keywords(:attributes)
    end

    context 'when the resource does not define permitted attributes' do
      let(:resource) { Cuprum::Rails::Resource.new(name: 'books') }
      let(:expected_error) do
        Cuprum::Rails::Errors::ResourceError.new(
          message:  "permitted attributes can't be blank",
          resource:
        )
      end

      it 'should return a failing result' do
        expect(command.call(attributes:))
          .to be_a_failing_result
          .with_error(expected_error)
      end

      context 'when initialized with require_permitted_attributes: false' do
        let(:options) { super().merge(require_permitted_attributes: false) }

        include_deferred 'should filter the attributes'
      end
    end

    context 'when the permitted attributes are an empty array' do
      let(:permitted_attributes) { [] }
      let(:expected_error) do
        Cuprum::Rails::Errors::ResourceError.new(
          message:  "permitted attributes can't be blank",
          resource:
        )
      end

      it 'should return a failing result' do
        expect(command.call(attributes:))
          .to be_a_failing_result
          .with_error(expected_error)
      end

      context 'when initialized with require_permitted_attributes: false' do
        let(:options) { super().merge(require_permitted_attributes: false) }

        include_deferred 'should filter the attributes'
      end
    end

    context 'when the permitted attributes are an array of strings' do
      let(:permitted_attributes) { super().map(&:to_s) }
      let(:expected_value) do
        attributes
          .then { |hsh| tools.hsh.convert_keys_to_strings(hsh) }
          .slice(*permitted_attributes)
      end

      include_deferred 'should filter the attributes'
    end

    context 'when the permitted attributes are an array of symbols' do
      let(:permitted_attributes) { super().map(&:intern) }
      let(:expected_value) do
        attributes
          .then { |hsh| tools.hsh.convert_keys_to_symbols(hsh) }
          .slice(*permitted_attributes)
      end

      include_deferred 'should filter the attributes'
    end
  end

  describe '#require_permitted_attributes?' do
    include_examples 'should define predicate',
      :require_permitted_attributes?,
      true

    context 'when initialized with require_permitted_attributes: false' do
      let(:options) { super().merge(require_permitted_attributes: false) }

      it { expect(command.require_permitted_attributes?).to be false }
    end

    context 'when initialized with require_permitted_attributes: true' do
      let(:options) { super().merge(require_permitted_attributes: true) }

      it { expect(command.require_permitted_attributes?).to be true }
    end
  end

  describe '#resource' do
    include_examples 'should define reader', :resource, -> { resource }
  end
end
