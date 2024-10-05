# frozen_string_literal: true

require 'cuprum/rails/command'
require 'cuprum/rails/commands/resources/concerns/permitted_attributes'
require 'cuprum/rails/resource'
require 'cuprum/rails/rspec/deferred/commands/resources_examples'

RSpec.describe \
  Cuprum::Rails::Commands::Resources::Concerns::PermittedAttributes \
do
  include Cuprum::Rails::RSpec::Deferred::Commands::ResourcesExamples

  subject(:command) { described_class.new(resource:) }

  let(:described_class)      { Spec::ExampleCommand }
  let(:permitted_attributes) { %w[title author] }
  let(:resource) do
    Cuprum::Rails::Resource.new(name: 'books', **resource_options)
  end
  let(:resource_options) { { permitted_attributes: } }

  example_class 'Spec::ExampleCommand', Cuprum::Rails::Command do |klass|
    klass.include \
      Cuprum::Rails::Commands::Resources::Concerns::PermittedAttributes # rubocop:disable RSpec/DescribedClass

    klass.define_method(:process) do |attributes:|
      permit_attributes(attributes:)
    end
  end

  describe '#call' do
    deferred_examples 'should filter the attributes' do
      describe 'with String keys' do
        it 'should return a passing result' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(expected_value)
        end
      end

      describe 'with Symbol keys' do
        let(:attributes) do
          tools.hash_tools.convert_keys_to_symbols(super())
        end

        it 'should return a passing result' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(expected_value)
        end
      end
    end

    let(:attributes) { {} }

    def call_command
      command.call(attributes:)
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    include_deferred 'should require permitted attributes'

    context 'when the command does not require permitted attributes' do
      let(:attributes) do
        {
          'title'  => 'Gideon the Ninth',
          'author' => 'Tamsyn Muir',
          'rating' => '5 stars'
        }
      end

      before(:example) do
        described_class.define_method(:require_permitted_attributes?) do
          false
        end
      end

      context 'when a resource with permitted_attributes: nil' do
        let(:resource_options) { super().merge(permitted_attributes: nil) }

        it 'should return a passing result' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(attributes)
        end
      end

      context 'when a resource with permitted_attributes: an empty Array' do
        let(:resource_options) { super().merge(permitted_attributes: []) }

        it 'should return a passing result' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(attributes)
        end
      end
    end

    describe 'with empty attributes' do
      let(:attributes)     { {} }
      let(:expected_value) { attributes }

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_value)
      end
    end

    describe 'with attributes: a subset of the permitted attributes' do
      let(:attributes)     { { 'title' => 'Gideon the Ninth' } }
      let(:expected_value) { { 'title' => 'Gideon the Ninth' } }

      include_deferred 'should filter the attributes'
    end

    describe 'with attributes: the permitted attributes' do
      let(:attributes) do
        {
          'title'  => 'Gideon the Ninth',
          'author' => 'Tamsyn Muir'
        }
      end
      let(:expected_value) do
        {
          'title'  => 'Gideon the Ninth',
          'author' => 'Tamsyn Muir'
        }
      end

      include_deferred 'should filter the attributes'
    end

    describe 'with attributes: a superset of the permitted attributes' do
      let(:attributes) do
        {
          'title'  => 'Gideon the Ninth',
          'author' => 'Tamsyn Muir',
          'rating' => '5 stars'
        }
      end
      let(:expected_value) do
        {
          'title'  => 'Gideon the Ninth',
          'author' => 'Tamsyn Muir'
        }
      end

      include_deferred 'should filter the attributes'
    end
  end
end
