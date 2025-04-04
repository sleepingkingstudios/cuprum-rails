# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred/provider'

require 'cuprum/rails/rspec/deferred/commands/resources'
require 'cuprum/rails/rspec/deferred/commands/resources_examples'

module Cuprum::Rails::RSpec::Deferred::Commands::Resources
  # Deferred examples for validating New command implementations.
  module NewExamples
    include RSpec::SleepingKingStudios::Deferred::Provider
    include Cuprum::Rails::RSpec::Deferred::Commands::ResourcesExamples

    # Examples that assert that the command builds an entity.
    #
    # The following examples are defined:
    #
    # - The command should return a passing result, with the result value equal
    #   to the newly instantiated entity.
    # - The attributes of the returned entity should match the expected
    #   attributes.
    #
    # The following methods must be defined in the example group:
    #
    # - #call_command: A method that calls the command being tested with all
    #   required parameters.
    # - #expected_attributes: A hash containing the expected attributes for the
    #   created entity. The hash can contain or be wrapped in RSpec matchers,
    #   such as when asserting that a timestamp is any time value.
    deferred_examples 'should build the entity' do
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
    end

    # Examples that assert the command implements the New contract.
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
    deferred_examples 'should implement the New command' \
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
        let(:empty_attributes) do
          next super() if defined?(super())

          {}
        end
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
          let(:matched_attributes) { {} }

          include_deferred 'should build the entity'
        end

        describe 'with attributes: an Hash with invalid attributes' do
          let(:matched_attributes) { invalid_attributes }

          include_deferred 'should build the entity'
        end

        describe 'with attributes: a Hash with String keys' do
          let(:matched_attributes) do
            tools
              .hash_tools
              .convert_keys_to_strings(configured_valid_attributes)
          end

          include_deferred 'should build the entity'
        end

        describe 'with attributes: a Hash with Symbol keys' do
          let(:matched_attributes) do
            tools
              .hash_tools
              .convert_keys_to_symbols(configured_valid_attributes)
          end

          include_deferred 'should build the entity'
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
            empty_attributes.merge(configured_valid_attributes)
          end

          include_deferred 'should build the entity'
        end

        instance_exec(&block) if block
      end
    end
  end
end
