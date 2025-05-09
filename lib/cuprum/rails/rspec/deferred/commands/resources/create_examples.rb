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

    # Examples that assert that the command creates an entity.
    #
    # The following examples are defined:
    #
    # - The command should return a passing result, with the result value equal
    #   to the newly created entity.
    # - The attributes of the returned entity should match the expected
    #   attributes.
    # - Calling the command should increment the collection count by 1.
    # - After calling the command, the collection should include one item whose
    #   attributes match the expected attributes.
    #
    # The following methods must be defined in the example group:
    #
    # - #call_command: A method that calls the command being tested with all
    #   required parameters.
    # - #expected_attributes: A hash containing the expected attributes for the
    #   created entity. The hash can contain or be wrapped in RSpec matchers,
    #   such as when asserting that a timestamp is any time value.
    #
    # The behavior can be customized by defining the following methods:
    #
    # - #expected_value: The value returned by the command. Defaults to an
    #   instance of the entity class matching #expected_attributes.
    deferred_examples 'should create the entity' do
      include RSpec::SleepingKingStudios::Deferred::Dependencies

      depends_on :call_command,
        'method that calls the command being tested with required parameters'
      depends_on :expected_attributes,
        'a Hash containing the expected attributes for the created entity'

      let(:entity_class) { collection.entity_class }
      let(:expected_value) do
        next super() if defined?(super())

        next match(expected_attributes) if entity_class <= Hash

        an_instance_of(entity_class).and have_attributes(expected_attributes)
      end

      it 'should return a passing result', :aggregate_failures do
        result = call_command

        expect(result).to be_a_passing_result
        expect(result.value).to match(expected_value)
      end

      it { expect { call_command }.to change { persisted_data.count }.by(1) } # rubocop:disable RSpec/ExpectChange

      it 'should add the entity to the collection' do # rubocop:disable RSpec/ExampleLength
        expect { call_command }.to(
          change { persisted_data }.to(
            satisfy do |data|
              data.any? do |item|
                match(expected_attributes).matches?(attributes_for(item))
              end
            end
          )
        )
      end
    end

    # Examples that assert the command implements the Create contract.
    #
    # The following methods must be defined in the example group:
    #
    # - #extra_attributes: A Hash containing attributes that are not defined for
    #   the entity such as when asserting that a timestamp is any time value.
    #   The value must not include any defined attributes.
    # - #invalid_attributes: An attributes Hash that will fail validation - will
    #   preferentially use #invalid_attributes_for_create if present.
    # - #valid_attributes: An attributes Hash that will pass validation - will
    #   preferentially use #valid_attributes_for_create if present.
    #
    # To access the actual attributes for each case, call #matched_attributes.
    #
    # The behavior can be customized by defining the following methods:
    #
    # - #empty_attributes: A Hash containing the attributes for a newly built
    #   entity when given no parameters. Use this method when creating an object
    #   that initializes its properties to null or default values.
    # - #expected_attributes: A Hash containing the expected attributes when
    #   creating an object. Defaults to the matched attributes merged into the
    #   empty attributes.
    # - #valid_attributes_for_create: An attributes Hash that will pass
    #   validation. This method overrides #valid_attributes if present.
    deferred_examples 'should implement the Create command' \
    do |**examples_opts, &block|
      include RSpec::SleepingKingStudios::Deferred::Dependencies

      depends_on :extra_attributes,
        'a Hash containing attributes that are not defined for the entity'
      depends_on :invalid_attributes,
        'an attributes Hash that will fail validation - will preferentially' \
        'use #invalid_attributes_for_create if present'
      depends_on :valid_attributes,
        'an attributes Hash that will pass validation - will preferentially' \
        'use #valid_attributes_for_create if present'

      describe '#call' do
        let(:default_contract) do
          next super() if defined?(super())

          nil
        end
        let(:empty_attributes) { defined?(super()) ? super() : {} }
        let(:expected_attributes) do
          next super() if defined?(super())

          empty_attributes.merge(
            tools.hash_tools.convert_keys_to_strings(matched_attributes)
          )
        end

        define_method :call_command do
          return super() if defined?(super())

          command.call(attributes: matched_attributes)
        end

        define_method :configured_valid_attributes do
          if defined?(valid_attributes_for_create)
            # :nocov:
            return valid_attributes_for_create
            # :nocov:
          end

          valid_attributes
        end

        define_method :tools do
          SleepingKingStudios::Tools::Toolbelt.instance
        end

        include_deferred 'when the collection is defined'

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
          let(:matched_attributes) { {} }

          include_deferred 'should validate the entity'

          include_deferred 'should not create an entity'
        end

        describe 'with attributes: an Hash with invalid attributes' do
          let(:matched_attributes) { invalid_attributes }

          include_deferred 'should validate the entity'

          include_deferred 'should not create an entity'
        end

        describe 'with attributes: a Hash with String keys' do
          let(:matched_attributes) do
            tools
              .hash_tools
              .convert_keys_to_strings(configured_valid_attributes)
          end

          include_deferred 'should create the entity'
        end

        describe 'with attributes: a Hash with Symbol keys' do
          let(:matched_attributes) do
            tools
              .hash_tools
              .convert_keys_to_symbols(configured_valid_attributes)
          end

          include_deferred 'should create the entity'
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
            empty_attributes.merge(super().except(*extra_attributes.keys))
          end

          include_deferred 'should create the entity'
        end

        instance_exec(&block) if block
      end
    end

    # Examples that assert the commend does not create an entity.
    #
    # The following methods must be defined in the example group:
    #
    # - #call_command: A method that calls the command being tested with all
    #   required parameters.
    deferred_examples 'should not create an entity' do
      it { expect { call_command }.not_to(change { persisted_data }) }
    end
  end
end
