# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred/provider'

require 'cuprum/rails/rspec/deferred/commands/resources'
require 'cuprum/rails/rspec/deferred/commands/resources_examples'

module Cuprum::Rails::RSpec::Deferred::Commands::Resources
  # Deferred examples for validating Update command implementations.
  module UpdateExamples
    include RSpec::SleepingKingStudios::Deferred::Provider
    include Cuprum::Rails::RSpec::Deferred::Commands::ResourcesExamples

    def attributes_for(item)
      item.is_a?(Hash) ? item : item&.attributes
    end

    def persisted_data
      return super if defined?(super)

      repository[resource.qualified_name]
        .find_matching
        .call
        .value
        .to_a
    end

    deferred_examples 'should implement the Update command' do |**examples_opts|
      include Cuprum::Rails::RSpec::Deferred::Commands::ResourcesExamples

      describe '#call' do
        let(:default_contract) do
          next super() if defined?(super())

          nil
        end

        define_method(:call_command) do
          return super() if defined?(super())

          command.call(
            attributes:  defined?(attributes)  ? attributes  : {},
            entity:      defined?(entity)      ? entity      : nil,
            primary_key: defined?(primary_key) ? primary_key : nil
          )
        end

        define_method(:tools) do
          SleepingKingStudios::Tools::Toolbelt.instance
        end

        before(:example) do
          options = default_contract ? { default_contract: } : {}

          repository
            .create(qualified_name: resource.qualified_name, **options)
        end

        it 'should define the method' do
          expect(command)
            .to be_callable
            .with(0).arguments
            .and_keywords(:attributes, :entity, :primary_key)
            .and_any_keywords
        end

        unless examples_opts.fetch(:default_contract, false)
          # @todo: This should be a deferred context.
          describe 'with a valid entity' do
            let(:entity) do
              defined?(super()) ? super() : collection_data[0]
            end

            include_deferred 'when the collection has many items'

            include_deferred 'should require default contract'
          end
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
          let!(:original_attributes) do
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

          describe 'with attributes: an empty Hash' do
            let(:attributes)          { {} }
            let(:expected_attributes) { original_attributes }

            include_deferred 'should update the entity'
          end

          describe 'with attributes: an Hash with invalid attributes' do
            let(:attributes) { invalid_attributes }
            let(:expected_attributes) do
              original_attributes.merge(invalid_attributes)
            end

            include_deferred 'should validate the entity'

            include_deferred 'should not update the entity'
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

    deferred_examples 'should not update the entity' do
      it { expect { call_command }.not_to(change { persisted_data }) }
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

      it { expect(entity_attributes).to match(expected_attributes) }

      it { expect { call_command }.not_to(change { persisted_data.count }) } # rubocop:disable RSpec/ExpectChange

      it 'should update the entity in the collection' do # rubocop:disable RSpec/ExampleLength
        call_command

        primary_key    = original_attributes[resource.primary_key_name]
        updated_entity = persisted_data.find do |entity|
          entity[resource.primary_key_name] == primary_key
        end

        expect(attributes_for(updated_entity)).to match(expected_attributes)
      end
    end
  end
end
