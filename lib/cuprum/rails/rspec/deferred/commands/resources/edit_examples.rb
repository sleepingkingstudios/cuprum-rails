# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred/provider'

require 'cuprum/rails/rspec/deferred/commands/resources'
require 'cuprum/rails/rspec/deferred/commands/resources_examples'

module Cuprum::Rails::RSpec::Deferred::Commands::Resources
  # Deferred examples for validating Edit command implementations.
  module EditExamples
    include RSpec::SleepingKingStudios::Deferred::Provider
    include Cuprum::Rails::RSpec::Deferred::Commands::ResourcesExamples

    deferred_examples 'should implement the Edit command' do |**examples_opts|
      include Cuprum::Rails::RSpec::Deferred::Commands::ResourcesExamples

      describe '#call' do
        def call_command
          return super if defined?(super)

          command.call(
            attributes:  defined?(attributes)  ? attributes  : {},
            entity:      defined?(entity)      ? entity      : nil,
            primary_key: defined?(primary_key) ? primary_key : nil
          )
        end

        it 'should define the method' do
          expect(command)
            .to be_callable
            .with(0).arguments
            .and_keywords(:attributes, :entity, :primary_key)
            .and_any_keywords
        end

        if examples_opts.fetch(:require_permitted_attributes, true)
          describe 'with a valid entity' do
            let(:entity) do
              defined?(super()) ? super() : collection_data[0]
            end

            include_deferred 'when the collection has many items'

            include_deferred 'should require permitted attributes'
          end
        end

        include_deferred('should require entity', **examples_opts)

        include_deferred('with a valid entity', **examples_opts) do
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
          let(:original_attributes) do
            next super() if defined?(super())

            value = expected_entity

            value.is_a?(Hash) ? value : value.attributes
          end
          let(:expected_attributes) do
            next super() if defined?(super())

            original_attributes.merge(
              'title'  => 'Gideon the Ninth',
              'author' => 'Tamsyn Muir'
            )
          end

          define_method(:tools) do
            SleepingKingStudios::Tools::Toolbelt.instance
          end

          describe 'with attributes: an empty Hash' do
            let(:attributes)          { {} }
            let(:expected_attributes) { original_attributes }

            include_deferred 'should update the entity'
          end

          describe 'with attributes: a Hash with String keys' do
            let(:attributes) do
              tools.hash_tools.convert_keys_to_strings(super())
            end

            include_deferred 'should update the entity'
          end

          describe 'with attributes: a Hash with Symbol keys' do
            let(:attributes) do
              tools.hash_tools.convert_keys_to_symbols(super())
            end

            include_deferred 'should update the entity'
          end

          describe 'with attributes: a Hash with extra attributes' do
            let(:attributes) { super().merge(extra_attributes) }

            include_deferred 'should update the entity'
          end
        end
      end
    end

    deferred_examples 'should update the entity' do
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
    end
  end
end
