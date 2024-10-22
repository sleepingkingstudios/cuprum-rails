# frozen_string_literal: true

require 'stannum/constraints/presence'
require 'stannum/contracts/hash_contract'

require 'cuprum/rails/commands/resources/concerns/entity_validation'
require 'cuprum/rails/rspec/deferred/commands/resources_examples'

require 'support/examples/commands/resource_command_examples'

RSpec.describe Cuprum::Rails::Commands::Resources::Concerns::EntityValidation do
  include Cuprum::Rails::RSpec::Deferred::Commands::ResourcesExamples
  include Spec::Support::Examples::Commands::ResourceCommandExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:described_class) { Spec::ExampleCommand }
  let(:default_contract) do
    Stannum::Contracts::HashContract.new(allow_extra_keys: true) do
      key 'author', Stannum::Constraints::Presence.new
      key 'title',  Stannum::Constraints::Presence.new
    end
  end

  example_class 'Spec::ExampleCommand',
    Cuprum::Rails::Commands::ResourceCommand \
  do |klass|
    klass.include Cuprum::Rails::Commands::Resources::Concerns::EntityValidation # rubocop:disable RSpec/DescribedClass

    klass.define_method(:process) do |entity:|
      validate_entity(entity:)
    end
  end

  before(:example) do
    next unless default_contract

    repository.create(
      default_contract:,
      qualified_name:   resource.qualified_name
    )
  end

  include_deferred 'with parameters for a resource command'

  describe '#call' do
    let(:entity) do
      repository.find_or_create(qualified_name: resource.qualified_name)
        .build_one
        .call(attributes:)
        .value
    end
    let(:attributes)          { {} }
    let(:expected_attributes) { attributes }

    def call_command
      command.call(entity:)
    end

    include_deferred 'should require default contract'

    describe 'with attributes: an empty Hash' do
      let(:attributes) { {} }

      include_deferred 'should validate the entity'
    end

    describe 'with attributes: an Hash with invalid attributes' do
      let(:attributes) do
        {
          'title'  => 'Gideon the Ninth',
          'author' => nil
        }
      end

      include_deferred 'should validate the entity'
    end

    describe 'with attributes: a Hash with String keys' do
      let(:attributes) do
        {
          'title'  => 'Gideon the Ninth',
          'author' => 'Tamsyn Muir'
        }
      end

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_attributes)
      end
    end

    describe 'with attributes: a Hash with Symbol keys' do
      let(:attributes) do
        {
          title:  'Gideon the Ninth',
          author: 'Tamsyn Muir'
        }
      end
      let(:expected_attributes) do
        tools.hash_tools.convert_keys_to_strings(super())
      end

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_attributes)
      end
    end
  end
end
