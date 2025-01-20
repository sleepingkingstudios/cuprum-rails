# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred/provider'

require 'cuprum/rails/rspec/deferred/commands/resources'
require 'cuprum/rails/rspec/deferred/commands/resources_examples'

module Cuprum::Rails::RSpec::Deferred::Commands::Resources
  # Deferred examples for validating Create command implementations.
  module CreateExamples
    include RSpec::SleepingKingStudios::Deferred::Provider
    include Cuprum::Rails::RSpec::Deferred::Commands::ResourcesExamples

    define_method :attributes_for do |item|
      item.is_a?(Hash) ? item : item&.attributes
    end

    define_method :persisted_data do
      return super if defined?(super)

      repository[resource.qualified_name]
        .find_matching
        .call
        .value
        .to_a
    end

    deferred_examples 'should create the entity' do
      let(:entity_class) do
        repository
          .find_or_create(qualified_name: resource.qualified_name)
          .entity_class
      end
      let(:entity_attributes) do
        next super() if defined?(super())

        value = call_command.value

        value.is_a?(Hash) ? value : value.attributes
      end

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(an_instance_of(entity_class))
      end

      it { expect(entity_attributes).to be == expected_attributes }

      it { expect { call_command }.to change { persisted_data.count }.by(1) }

      it 'should add the entity to the collection' do
        expect { call_command }.to(
          change { persisted_data }.to(
            satisfy do |data|
              data.any? { |item| attributes_for(item) == expected_attributes }
            end
          )
        )
      end
    end

    deferred_examples 'should implement the Create command' do |**examples_opts|
      describe '#call' do
        let(:default_contract) do
          next super() if defined?(super())

          nil
        end
        let(:attributes) do
          next super() if defined?(super())

          {
            'title'  => 'Gideon the Ninth',
            'author' => 'Tamsyn Muir'
          }
        end
        let(:invalid_attributes) do
          next super() if defined?(super())

          {
            'title'  => 'Gideon the Ninth',
            'author' => nil
          }
        end
        let(:extra_attributes) do
          next super() if defined?(super())

          {
            'published_at' => '2019-09-10'
          }
        end
        let(:empty_attributes) do
          next super() if defined?(super())

          {}
        end
        let(:expected_attributes) do
          next super() if defined?(super())

          empty_attributes.merge(
            'title'  => 'Gideon the Ninth',
            'author' => 'Tamsyn Muir'
          )
        end

        def call_command
          defined?(super) ? super : command.call(attributes:)
        end

        def tools
          SleepingKingStudios::Tools::Toolbelt.instance
        end

        before(:example) do
          options = default_contract ? { default_contract: } : {}

          repository.create(qualified_name: resource.qualified_name, **options)
        end

        it 'should define the method' do
          expect(command)
            .to be_callable
            .with(0).arguments
            .and_keywords(:attributes)
            .and_any_keywords
        end

        unless examples_opts.fetch(:default_contract, false)
          include_deferred 'should require default contract'
        end

        if examples_opts.fetch(:require_permitted_attributes, true)
          include_deferred 'should require permitted attributes'
        end

        describe 'with attributes: an empty Hash' do
          let(:attributes)          { {} }
          let(:expected_attributes) { empty_attributes }

          include_deferred 'should validate the entity'

          include_deferred 'should not create an entity'
        end

        describe 'with attributes: an Hash with invalid attributes' do
          let(:attributes) { invalid_attributes }
          let(:expected_attributes) do
            empty_attributes.merge(invalid_attributes)
          end

          include_deferred 'should validate the entity'

          include_deferred 'should not create an entity'
        end

        describe 'with attributes: a Hash with String keys' do
          let(:attributes) { tools.hash_tools.convert_keys_to_strings(super()) }

          include_deferred 'should create the entity'
        end

        describe 'with attributes: a Hash with Symbol keys' do
          let(:attributes) { tools.hash_tools.convert_keys_to_symbols(super()) }

          include_deferred 'should create the entity'
        end

        describe 'with attributes: a Hash with extra attributes' do
          let(:attributes) { super().merge(extra_attributes) }

          include_deferred 'should create the entity'
        end
      end
    end

    deferred_examples 'should not create an entity' do
      it { expect { call_command }.not_to(change { persisted_data }) }
    end
  end
end
