# frozen_string_literal: true

require 'rspec/sleeping_king_studios/contract'

require 'cuprum/rails/rspec/actions'
require 'cuprum/rails/rspec/actions_contracts'
require 'cuprum/rails/rspec/contract_helpers'

module Cuprum::Rails::RSpec::Actions
  # Namespace for RSpec update contracts, which validate update implementations.
  module UpdateContracts
    # Contract asserting the action implements the show action interface.
    module UpdateActionContract
      extend RSpec::SleepingKingStudios::Contract

      # @method apply(example_group, existing_entity:, **options)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] The example group to
      #     which the contract is applied.
      #   @param existing_entity [Object] The existing entity to update.
      #   @param invalid_attributes [Hash<String>] A set of attributes that will
      #     fail validation.
      #   @param valid_attributes [Hash<String>] A set of attributes that will
      #     pass validation.
      #
      #   @option options [Hash<String>] expected_value_on_success The expected
      #     value for the passing result. Defaults to a Hash with the found
      #     entity.
      #   @option options [Hash<String>] expected_attributes_on_failure The
      #     expected attributes for a failed validation. Defaults to the value
      #     of invalid_attributes.
      #   @option options [Hash<String>] expected_attributes_on_success The
      #     expected attributes for the returned object. Defaults to the value
      #     of valid_attributes.
      #   @option options [Hash<String>] expected_value_on_success The expected
      #     value for the passing result. Defaults to a Hash with the updated
      #     entity.
      #   @option options [#to_proc] examples_on_success Extra examples to run
      #     for the passing case.
      #   @option options [Hash<String>] params The parameters used to build the
      #     request. Defaults to the id of the entity and the given attributes.
      #   @option options [Object] primary_key_value The value of the primary
      #     key for the missing entity.

      contract do |existing_entity:, invalid_attributes:, valid_attributes:, **options| # rubocop:disable Layout/LineLength
        include Cuprum::Rails::RSpec::ActionsContracts
        include Cuprum::Rails::RSpec::Actions::UpdateContracts

        configured_params = lambda do
          attributes =
            Cuprum::Rails::RSpec::ContractHelpers.option_with_default(
              configured: valid_attributes,
              context:    self
            )
          entity =
            Cuprum::Rails::RSpec::ContractHelpers.option_with_default(
              configured: existing_entity,
              context:    self
            )

          resource = action.resource.singular_resource_name
          Cuprum::Rails::RSpec::ContractHelpers.option_with_default(
            configured: options[:params],
            context:    self,
            default:    {
              'id'     => entity[action.resource.primary_key],
              resource => attributes
            }
          )
        end

        should_not_update_the_entity = lambda do
          it 'should not update the entity' do
            entity = existing_entity
            entity = instance_exec(&entity) if entity.is_a?(Proc)

            expect { action.call(request: request) }
              .not_to(change { entity.reload.attributes })
          end
        end

        include_contract 'resource action contract'

        include_contract(
          'should require permitted attributes',
          params: configured_params,
          &should_not_update_the_entity
        )

        include_contract(
          'should require primary key',
          params: configured_params,
          &should_not_update_the_entity
        )

        include_contract(
          'should require parameters',
          params: configured_params,
          &should_not_update_the_entity
        )

        include_contract(
          'should require existing entity',
          params:            configured_params,
          primary_key_value: options[:primary_key_value],
          &should_not_update_the_entity
        )

        include_contract(
          'should validate attributes',
          existing_entity:     existing_entity,
          expected_attributes: options[:expected_attributes_on_failure],
          invalid_attributes:  invalid_attributes,
          params:              configured_params,
          &should_not_update_the_entity
        )

        include_contract(
          'should update the entity',
          existing_entity:     existing_entity,
          expected_attributes: options[:expected_attributes_on_success],
          expected_value:      options[:expected_value_on_success],
          valid_attributes:    valid_attributes,
          params:              configured_params,
          &options[:examples_on_success]
        )
      end
    end

    # Contract asserting the action updates the entity.
    module ShouldUpdateTheEntityContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, existing_entity:, valid_attributes:, **options) # rubocop:disable Layout/LineLength
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] The example group to
      #     which the contract is applied.
      #   @param existing_entity [Object] The existing entity to find.
      #   @param valid_attributes [Hash<String>] A set of attributes that will
      #     pass validation.
      #
      #   @option options [Hash<String>] expected_attributes The expected
      #     attributes for the returned object. Defaults to the value of
      #     valid_attributes.
      #   @option options [Hash<String>] expected_value The expected value for
      #     the passing result. Defaults to a Hash with the created entity.
      #   @option options [Hash<String>] params The parameters used to build the
      #     request. Defaults to the id of the entity and the given attributes.
      #
      #   @yield Additional examples.
      contract do |existing_entity:, valid_attributes:, **options, &block|
        describe '#call' do
          include Cuprum::Rails::RSpec::ContractHelpers

          let(:params) do
            option_with_default(configured: options[:params])
          end
          let(:request) do
            instance_double(Cuprum::Rails::Request, params: params)
          end

          context 'with valid parameters' do
            let(:existing_entity) do
              option_with_default(
                configured: existing_entity,
                context:    self
              )
            end
            let(:valid_attributes) do
              option_with_default(configured: valid_attributes)
            end
            let(:expected_attributes) do
              option_with_default(
                configured: options[:expected_attributes],
                default:    self.existing_entity.attributes.merge(
                  self.valid_attributes
                )
              )
            end
            let(:params) do
              super().merge({
                action.resource.singular_resource_name => self.valid_attributes
              })
            end
            let(:expected_entity) do
              action
                .resource
                .resource_class
                .find(params['id'])
            end
            let(:expected_value) do
              option_with_default(
                configured: options[:expected_value],
                context:    self,
                default:    {
                  action.resource.singular_resource_name => expected_entity
                }
              )
            end

            it 'should return a passing result' do
              expect(action.call(request: request))
                .to be_a_passing_result
                .with_value(expected_value)
            end

            it 'should update the entity' do
              expect { action.call(request: request) }
                .to change { self.existing_entity.reload.attributes }
                .to be <= expected_attributes
            end

            instance_exec(&block) if block
          end
        end
      end
    end
  end
end
