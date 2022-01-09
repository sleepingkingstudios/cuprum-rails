# frozen_string_literal: true

require 'rspec/sleeping_king_studios/contract'

require 'cuprum/rails/rspec/actions'
require 'cuprum/rails/rspec/actions_contracts'
require 'cuprum/rails/rspec/contract_helpers'

module Cuprum::Rails::RSpec::Actions
  # Namespace for RSpec destroy contracts, which validate destroy
  # implementations.
  module DestroyContracts
    # Contract asserting the action implements the destroy action interface.
    module DestroyActionContract
      extend RSpec::SleepingKingStudios::Contract

      # @method apply(example_group, existing_entity:, **options)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] The example group to
      #     which the contract is applied.
      #   @param existing_entity [Object] The existing entity to destroy.
      #
      #   @option options [Hash<String>] expected_value_on_success The expected
      #     value for the passing result. Defaults to a Hash with the destroyed
      #     entity.
      #   @option options [Object] primary_key_value The value of the primary
      #     key for the missing entity.

      contract do |existing_entity:, **options|
        include Cuprum::Rails::RSpec::ActionsContracts
        include Cuprum::Rails::RSpec::Actions::DestroyContracts

        should_not_destroy_the_entity = lambda do
          it 'should not destroy the entity' do
            expect { action.call(request: request) }
              .not_to change(action.resource.resource_class, :count)
          end
        end

        include_contract 'resource action contract'

        include_contract(
          'should require primary key',
          &should_not_destroy_the_entity
        )

        include_contract(
          'should require existing entity',
          primary_key_value: options[:primary_key_value],
          &should_not_destroy_the_entity
        )

        include_contract(
          'should destroy the entity',
          existing_entity: existing_entity,
          expected_value:  options[:expected_value_on_success]
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
      #
      #   @yield Additional configuration or examples.

      contract do |existing_entity:, **contract_options, &block|
        contract_options = contract_options.merge(
          existing_entity: existing_entity
        )

        describe '#call' do
          include Cuprum::Rails::RSpec::ContractHelpers

          let(:params) do
            defined?(super()) ? super() : {}
          end
          let(:request) do
            instance_double(Cuprum::Rails::Request, params: params)
          end

          context 'when the entity exists' do
            let(:existing_entity) do
              option_with_default(
                configured: contract_options[:existing_entity],
                context:    self
              )
            end
            let(:primary_key) { resource.primary_key }
            let(:params) do
              super().merge('id' => self.existing_entity[primary_key])
            end
            let(:expected_value) do
              option_with_default(
                configured: contract_options[:expected_value],
                context:    self,
                default:    {
                  action.resource.singular_resource_name => self.existing_entity
                }
              )
            end

            it 'should return a passing result' do
              expect(action.call(request: request))
                .to be_a_passing_result
                .with_value(expected_value)
            end

            it 'should destroy the entity', :aggregate_failures do
              expect { action.call(request: request) }
                .to change(action.resource.resource_class, :count)
                .by(-1)

              expect(
                action
                .resource
                .resource_class
                .exists?(primary_key => self.existing_entity[primary_key])
              ).to be false
            end

            instance_exec(&block) if block
          end
        end
      end
    end
  end
end
