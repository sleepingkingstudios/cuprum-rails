# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred/provider'

require 'cuprum/rails/rspec/deferred/commands/resources'
require 'cuprum/rails/rspec/deferred/commands/resources_examples'

module Cuprum::Rails::RSpec::Deferred::Commands::Resources
  # Deferred examples for validating Edit command implementations.
  module EditExamples
    include RSpec::SleepingKingStudios::Deferred::Provider
    include Cuprum::Rails::RSpec::Deferred::Commands::ResourcesExamples

    # Examples that assert the command implements the Edit contract.
    #
    # The following methods must be defined in the example group:
    #
    # - #extra_attributes: A Hash containing attributes that are not defined for
    #   the entity such as when asserting that a timestamp is any time value.
    #   The value must not include any defined attributes.
    #
    # To access the actual entity for each case, call #matched_entity. To access
    # the actual attributes for each case, call #matched_attributes.
    #
    # The behavior can be customized by defining the following methods:
    #
    # - #entity: The entity directly passed to the command. Defaults to the
    #   first item in the fixtures.
    # - #expected_attributes: A Hash containing the expected attributes when
    #   creating an object. Defaults to the matched attributes merged into the
    #   original attributes.
    # - #original_attributes: The attributes for the entity before the command
    #   is called.
    # - #valid_primary_key_value: The value for the primary key for an unscoped
    #   collection. Defaults to the primary key value for the first item in the
    #   fixtures.
    # - #valid_scoped_primary_key_value: The value for the primary key for a
    #   scoped collection. Defaults to the primary key value for the first item
    #   in the collection that matches #resource_scope.
    deferred_examples 'should implement the Edit command' \
    do |**examples_opts, &block|
      include Cuprum::Rails::RSpec::Deferred::Commands::ResourcesExamples

      describe '#call' do
        define_method :call_command do
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

          define_method(:tools) do
            SleepingKingStudios::Tools::Toolbelt.instance
          end

          describe 'with attributes: an empty Hash' do
            let(:matched_attributes) { {} }

            include_deferred 'should update the entity attributes'
          end

          describe 'with attributes: a Hash with invalid attributes' do
            let(:matched_attributes) { invalid_attributes }

            include_deferred 'should update the entity attributes'
          end

          describe 'with attributes: a Hash with String keys' do
            let(:matched_attributes) do
              tools
                .hash_tools
                .convert_keys_to_strings(configured_valid_attributes)
            end

            include_deferred 'should update the entity attributes'
          end

          describe 'with attributes: a Hash with Symbol keys' do
            let(:matched_attributes) do
              tools
                .hash_tools
                .convert_keys_to_symbols(configured_valid_attributes)
            end

            include_deferred 'should update the entity attributes'
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
              original_attributes.merge(configured_valid_attributes)
            end

            include_deferred 'should update the entity attributes'
          end
        end

        instance_exec(&block) if block
      end
    end

    # Examples that assert that the command updates the entity's attributes.
    #
    # The following examples are defined:
    #
    # - The command should return a passing result, with the result value equal
    #   to the updated entity.
    # - The attributes of the returned entity should match the expected
    #   attributes.
    #
    # The following methods must be defined in the example group:
    #
    # - #call_command: A method that calls the command being tested with all
    #   required parameters.
    # - #expected_attributes: A hash containing the expected attributes for the
    #   updated entity. The hash can contain or be wrapped in RSpec matchers,
    #   such as when asserting that a timestamp is any time value.
    deferred_examples 'should update the entity attributes' do
      include RSpec::SleepingKingStudios::Deferred::Dependencies

      depends_on :call_command,
        'method that calls the command being tested with required parameters'
      depends_on :expected_attributes,
        'a Hash containing the expected attributes for the created entity'

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
  end
end
