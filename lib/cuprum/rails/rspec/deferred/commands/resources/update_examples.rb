# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred/provider'

require 'cuprum/rails/rspec/deferred/commands/resources'
require 'cuprum/rails/rspec/deferred/commands/resources_examples'
require 'cuprum/rails/rspec/matchers'

module Cuprum::Rails::RSpec::Deferred::Commands::Resources
  # Deferred examples for validating Update command implementations.
  module UpdateExamples
    include RSpec::SleepingKingStudios::Deferred::Provider
    include Cuprum::Rails::RSpec::Deferred::Commands::ResourcesExamples
    include Cuprum::Rails::RSpec::Matchers

    define_method :persisted_data do
      return super() if defined?(super())

      collection
        .find_matching
        .call
        .value
        .to_a
    end

    # Examples that assert the command implements the Update contract.
    #
    # The following methods must be defined in the example group:
    #
    # - #extra_attributes: A Hash containing attributes that are not defined for
    #   the entity such as when asserting that a timestamp is any time value.
    #   The value must not include any defined attributes.
    # - #invalid_attributes: An attributes Hash that will fail validation - will
    #   preferentially use #valid_attributes_for_update if present.
    # - #valid_attributes: An attributes Hash that will pass validation - will
    #   preferentially use #valid_attributes_for_update if present.
    #
    # The behavior can be customized by defining the following methods:
    #
    # - #empty_attributes: A Hash containing the attributes for a newly built
    #   entity when given no parameters. Use this method when creating an object
    #   that initializes its properties to null or default values.
    # - #entity: The entity directly passed to the command. Defaults to the
    #   first item in the fixtures.
    # - #expected_attributes: A Hash containing the expected attributes when
    #   creating an object. Defaults to the matched attributes merged into the
    #   empty attributes.
    # - #valid_attributes_for_update: An attributes Hash that will pass
    #   validation. This method overrides #valid_attributes if present.
    # - #valid_primary_key_value: The value for the primary key for an unscoped
    #   collection. Defaults to the primary key value for the first item in the
    #   fixtures.
    # - #valid_scoped_primary_key_value: The value for the primary key for a
    #   scoped collection. Defaults to the primary key value for the first item
    #   in the collection that matches #resource_scope.
    deferred_examples 'should implement the Update command' \
    do |**examples_opts, &block|
      include RSpec::SleepingKingStudios::Deferred::Dependencies
      include Cuprum::Rails::RSpec::Deferred::Commands::ResourcesExamples

      depends_on :extra_attributes,
        'a Hash containing attributes that are not defined for the entity'
      depends_on :invalid_attributes,
        'an attributes Hash that will fail validation - will preferentially' \
        'use #valid_attributes_for_update if present'
      depends_on :valid_attributes,
        'an attributes Hash that will pass validation - will preferentially' \
        'use #valid_attributes_for_update if present'

      describe '#call' do
        let(:default_contract) do
          defined?(super()) ? super() : nil
        end

        define_method(:call_command) do
          return super() if defined?(super())

          attributes = defined?(matched_attributes) ? matched_attributes : {}

          command.call(
            attributes:,
            entity:      defined?(entity)      ? entity      : nil,
            primary_key: defined?(primary_key) ? primary_key : nil
          )
        end

        define_method :configured_valid_attributes do
          if defined?(valid_attributes_for_update)
            # :nocov:
            return valid_attributes_for_update
            # :nocov:
          end

          valid_attributes
        end

        define_method(:tools) do
          SleepingKingStudios::Tools::Toolbelt.instance
        end

        include_deferred 'when the collection is defined'

        it 'should define the method' do
          expect(command)
            .to be_callable
            .with(0).arguments
            .and_keywords(:attributes, :entity, :primary_key)
            .and_any_keywords
        end

        unless examples_opts.fetch(:default_contract, false)
          describe 'with a valid entity' do
            let(:entity)             { matched_entity }
            let(:matched_attributes) { configured_valid_attributes }
            let(:matched_entity) do
              defined?(super()) ? super() : collection_data.first
            end

            include_deferred 'when the collection has many items'

            include_deferred 'should require default contract'
          end
        end

        if examples_opts.fetch(:require_permitted_attributes, true)
          describe 'with a valid entity' do
            let(:entity)             { matched_entity }
            let(:matched_attributes) { configured_valid_attributes }
            let(:matched_entity) do
              defined?(super()) ? super() : collection_data.first
            end

            include_deferred 'when the collection has many items'

            include_deferred 'should require permitted attributes'
          end
        end

        include_deferred('should require entity', **examples_opts)

        include_deferred('with a valid entity', **examples_opts) do
          let!(:original_attributes) do
            next super() if defined?(super())

            value = matched_entity

            value.is_a?(Hash) ? value : value.attributes
          end
          let(:expected_attributes) do
            next super() if defined?(super())

            original_attributes.merge(
              tools.hash_tools.convert_keys_to_strings(matched_attributes)
            )
          end

          describe 'with attributes: an empty Hash' do
            let(:matched_attributes) { {} }

            include_deferred 'should update the entity'
          end

          describe 'with attributes: an Hash with invalid attributes' do
            let(:matched_attributes) { invalid_attributes }

            include_deferred 'should validate the entity'

            include_deferred 'should not update the entity'
          end

          describe 'with attributes: a Hash with String keys' do
            let(:matched_attributes) do
              tools
                .hash_tools
                .convert_keys_to_strings(configured_valid_attributes)
            end

            include_deferred 'should update the entity'
          end

          describe 'with attributes: a Hash with Symbol keys' do
            let(:matched_attributes) do
              tools
                .hash_tools
                .convert_keys_to_symbols(configured_valid_attributes)
            end

            include_deferred 'should update the entity'
          end

          describe 'with attributes: a Hash with extra attributes' do
            let(:matched_attributes) do
              [
                configured_valid_attributes,
                extra_attributes
              ]
                .map { |hsh| tools.hash_tools.convert_keys_to_symbols(hsh) }
                .reduce(&:merge)
            end
            let(:expected_attributes) do
              original_attributes.merge(super().except(*extra_attributes.keys))
            end

            include_deferred 'should update the entity'
          end
        end

        instance_exec(&block) if block
      end
    end

    # Examples that assert the commend does not update the entity.
    #
    # The following methods must be defined in the example group:
    #
    # - #call_command: A method that calls the command being tested with all
    #   required parameters.
    deferred_examples 'should not update the entity' do
      include RSpec::SleepingKingStudios::Deferred::Dependencies

      depends_on :call_command,
        'method that calls the command being tested with required parameters'

      it { expect { call_command }.not_to(change { persisted_data }) }
    end

    # Examples that assert that the command updates the entity.
    #
    # The following examples are defined:
    #
    # - The command should return a passing result, with the result value an
    #   instance of the entity class.
    # - The attributes of the returned entity should match the expected
    #   attributes.
    # - Calling the command should not change the collection count.
    # - After calling the command, the item in the collection matching the
    #   entity's primary key should match the expected attributes.
    #
    # The behavior can be customized by defining the following methods:
    #
    # - #expected_value: The value returned by the command. Defaults to an
    #   instance of the entity class matching #expected_attributes.
    # - #persisted_value: The value saved to the collection. Defaults to the
    #   expected value.
    deferred_examples 'should update the entity' do
      include RSpec::SleepingKingStudios::Deferred::Dependencies

      depends_on :call_command,
        'method that calls the command being tested with required parameters'
      depends_on :expected_attributes,
        'a Hash containing the expected attributes for the created entity'

      let(:entity_class) { collection.entity_class }
      let(:expected_value) do
        # :nocov:
        next super() if defined?(super())

        next match(expected_attributes) if entity_class <= Hash

        if entity_class <= ActiveRecord::Base
          next match_record(
            attributes:   expected_attributes,
            record_class: entity_class
          )
        end

        an_instance_of(entity_class).and have_attributes(expected_attributes)
        # :nocov:
      end
      let(:persisted_value) do
        next super() if defined?(super())

        expected_value
      end

      it 'should return a passing result', :aggregate_failures do
        result = call_command

        expect(result).to be_a_passing_result
        expect(result.value).to match(expected_value)
      end

      it { expect { call_command }.not_to(change { persisted_data.count }) } # rubocop:disable RSpec/ExpectChange

      it 'should update the entity in the collection' do # rubocop:disable RSpec/ExampleLength
        entity = matched_entity

        call_command

        primary_key    = entity[resource.primary_key_name]
        updated_entity = persisted_data.find do |updated|
          updated[resource.primary_key_name] == primary_key
        end

        expect(updated_entity).to match(persisted_value)
      end
    end
  end
end
