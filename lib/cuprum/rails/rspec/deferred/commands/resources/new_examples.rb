# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred/provider'

require 'cuprum/rails/rspec/deferred/commands/resources'
require 'cuprum/rails/rspec/deferred/commands/resources_examples'

module Cuprum::Rails::RSpec::Deferred::Commands::Resources
  # Deferred examples for validating Index command implementations.
  module NewExamples
    include RSpec::SleepingKingStudios::Deferred::Provider
    include Cuprum::Rails::RSpec::Deferred::Commands::ResourcesExamples

    deferred_examples 'should build the entity' do
      let(:entity_class) { defined?(super()) ? super() : Hash }
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
    end

    deferred_examples 'should implement the New command' do |**examples_opts|
      describe '#call' do
        let(:attributes) do
          next super() if defined?(super())

          {
            'title'  => 'Gideon the Ninth',
            'author' => 'Tamsyn Muir'
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

        it 'should define the method' do
          expect(command)
            .to be_callable
            .with(0).arguments
            .and_keywords(:attributes)
            .and_any_keywords
        end

        if examples_opts.fetch(:require_permitted_attributes, true)
          include_deferred 'should require permitted attributes'
        end

        describe 'with attributes: an empty Hash' do
          let(:attributes)          { {} }
          let(:expected_attributes) { empty_attributes }

          include_deferred 'should build the entity'
        end

        describe 'with attributes: a Hash with String keys' do
          let(:attributes) { tools.hash_tools.convert_keys_to_strings(super()) }

          include_deferred 'should build the entity'
        end

        describe 'with attributes: a Hash with Symbol keys' do
          let(:attributes) { tools.hash_tools.convert_keys_to_symbols(super()) }

          include_deferred 'should build the entity'
        end

        describe 'with extra attributes' do
          let(:attributes) { super().merge(extra_attributes) }

          include_deferred 'should build the entity'
        end
      end
    end
  end
end
