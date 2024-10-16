# frozen_string_literal: true

require 'rspec/sleeping_king_studios/contract'

require 'cuprum/rails/rspec/contract_helpers'
require 'cuprum/rails/rspec/contracts/action_contracts'
require 'cuprum/rails/rspec/contracts/actions'

module Cuprum::Rails::RSpec::Contracts::Actions
  # Namespace for RSpec destroy contracts, which validate destroy
  # implementations.
  module DestroyContracts
    # Contract asserting the action implements the destroy action interface.
    module ShouldBeADestroyActionContract
      extend RSpec::SleepingKingStudios::Contract

      # @method apply(example_group, existing_entity:, **options)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] The example group to
      #     which the contract is applied.
      #   @param existing_entity [Object] The existing entity to destroy.
      #
      #   @option options [#to_proc] examples_on_failure Extra examples to run
      #     for the failing cases.
      #   @option options [#to_proc] examples_on_success Extra examples to run
      #     for the passing case.
      #   @option options [Hash<String>] expected_value_on_success The expected
      #     value for the passing result. Defaults to a Hash with the destroyed
      #     entity.
      #   @option options [Hash<String>] params The parameters used to build the
      #     request. Defaults to the id of the entity.
      #   @option options [Object] primary_key_value The value of the primary
      #     key for the missing entity.
      #
      #   @yield Additional examples to run for the passing case.

      contract do |existing_entity:, **options, &block|
        include Cuprum::Rails::RSpec::Contracts::ActionContracts
        include Cuprum::Rails::RSpec::Contracts::Actions::DestroyContracts

        # :nocov:
        if options[:examples_on_success] && block
          raise ArgumentError, 'provide either :examples_on_success or a block'
        elsif block
          options[:examples_on_success] = block
        end
        # :nocov:

        should_not_destroy_the_entity = lambda do
          it 'should not destroy the entity' do
            expect { call_action }
              .not_to change(configured_resource.entity_class, :count)
          end

          # :nocov:
          if options[:examples_on_failure]
            instance_exec(&options[:examples_on_failure])
          end
          # :nocov:
        end

        include_contract 'should be a resource action'

        include_contract(
          'should require primary key',
          params: options[:params],
          &should_not_destroy_the_entity
        )

        include_contract(
          'should require existing entity',
          params:            options[:params],
          primary_key_value: options[:primary_key_value],
          &should_not_destroy_the_entity
        )

        include_contract(
          'should destroy the entity',
          existing_entity:,
          expected_value:  options[:expected_value_on_success],
          params:          options[:params],
          &options[:examples_on_success]
        )
      end
    end

    # Contract asserting the action destroys the specified entity.
    module ShouldDestroyTheEntityContract
      extend RSpec::SleepingKingStudios::Contract

      # @method apply(example_group, existing_entity:, **options, &block)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] The example group to
      #     which the contract is applied.
      #   @param existing_entity [Object] The existing entity to destroy.
      #
      #   @option options [Hash<String>] expected_value The expected value for
      #     the passing result. Defaults to a Hash with the destroyed entity.
      #   @option options [Hash<String>] params The parameters used to build the
      #     request. Defaults to the id of the entity.
      #
      #   @yield Additional configuration or examples.

      contract do |existing_entity:, **options, &block|
        describe '#call' do
          include Cuprum::Rails::RSpec::ContractHelpers

          context 'when the entity exists' do
            let(:request) do
              Cuprum::Rails::Request.new(params: configured_params)
            end
            let(:configured_existing_entity) do
              option_with_default(existing_entity)
            end
            let(:configured_params) do
              resource_id =
                configured_existing_entity[configured_resource.primary_key]

              option_with_default(
                options[:params],
                default: { 'id' => resource_id }
              )
            end
            let(:configured_expected_value) do
              resource_name = configured_resource.singular_name

              option_with_default(
                options[:expected_value],
                default: {
                  resource_name => configured_existing_entity
                }
              )
            end

            it 'should return a passing result' do
              expect(call_action)
                .to be_a_passing_result
                .with_value(configured_expected_value)
            end

            it 'should destroy the entity', :aggregate_failures do
              expect { call_action }
                .to change(configured_resource.entity_class, :count)
                .by(-1)

              primary_key_name  = configured_resource.primary_key
              primary_key_value = configured_existing_entity[primary_key_name]
              expect(
                action
                .resource
                .entity_class
                .exists?(primary_key_name => primary_key_value)
              ).to be false
            end

            instance_exec(&block) if block
          end
        end
      end
    end
  end
end
