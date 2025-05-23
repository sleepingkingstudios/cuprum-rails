# frozen_string_literal: true

require 'rspec/sleeping_king_studios/contract'

require 'cuprum/rails/rspec/contract_helpers'
require 'cuprum/rails/rspec/contracts/action_contracts'
require 'cuprum/rails/rspec/contracts/actions'

module Cuprum::Rails::RSpec::Contracts::Actions
  # Namespace for RSpec update contracts, which validate update implementations.
  module UpdateContracts
    # @private
    def self.parameters(context:, resource:, **options) # rubocop:disable Metrics/MethodLength
      attributes    =
        Cuprum::Rails::RSpec::ContractHelpers.option_with_default(
          options[:valid_attributes],
          context:
        )
      entity        =
        Cuprum::Rails::RSpec::ContractHelpers.option_with_default(
          options[:existing_entity],
          context:
        )
      resource_name = resource.singular_name

      Cuprum::Rails::RSpec::ContractHelpers.option_with_default(
        options[:params],
        context:,
        default: {
          'id'          => entity[resource.primary_key],
          resource_name => attributes
        }
      )
    end

    # Contract asserting the action implements the show action interface.
    module ShouldBeAnUpdateActionContract
      extend RSpec::SleepingKingStudios::Contract

      # @method apply(example_group, existing_entity:, invalid_attributes:, valid_attributes:, **options)
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
      #   @option options [#to_proc] examples_on_failure Extra examples to run
      #     for the failing cases.
      #   @option options [#to_proc] examples_on_success Extra examples to run
      #     for the passing case.
      #   @option options [Hash<String>] expected_value_on_success The expected
      #     value for the passing result. Defaults to a Hash with the updated
      #     entity.
      #   @option options [Hash<String>] expected_attributes The expected
      #     attributes for both a failed validation and a returned entity.
      #   @option options [Hash<String>] expected_attributes_on_failure The
      #     expected attributes for a failed validation. Defaults to the value
      #     of invalid_attributes.
      #   @option options [Hash<String>] expected_attributes_on_success The
      #     expected attributes for the returned object. Defaults to the value
      #     of valid_attributes.
      #   @option options [Hash<String>] expected_value_on_success The expected
      #     value for the passing result. Defaults to a Hash with the updated
      #     entity.
      #   @option options [Hash<String>] params The parameters used to build the
      #     request. Defaults to the id of the entity and the given attributes.
      #   @option options [Object] primary_key_value The value of the primary
      #     key for the missing entity.
      #
      #   @yield Additional examples to run for the passing case.

      contract do |existing_entity:, invalid_attributes:, valid_attributes:, **options, &block| # rubocop:disable Layout/LineLength
        include Cuprum::Rails::RSpec::Contracts::ActionContracts
        include Cuprum::Rails::RSpec::Contracts::Actions::UpdateContracts

        # :nocov:
        if options[:examples_on_success] && block
          raise ArgumentError, 'provide either :examples_on_success or a block'
        elsif block
          options[:examples_on_success] = block
        end
        # :nocov:

        configured_params = lambda do
          Cuprum::Rails::RSpec::Contracts::Actions::UpdateContracts.parameters(
            context:          self,
            existing_entity:,
            resource:         configured_resource,
            valid_attributes:,
            **options
          )
        end

        should_not_update_the_entity = lambda do
          it 'should not update the entity' do
            entity = existing_entity
            entity = instance_exec(&entity) if entity.is_a?(Proc)

            expect { call_action }
              .not_to(change { entity.reload.attributes })
          end

          # :nocov:
          if options[:examples_on_failure]
            instance_exec(&options[:examples_on_failure])
          end
          # :nocov:
        end

        include_contract 'should be a resource action',
          require_permitted_attributes: true

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
          existing_entity:,
          expected_attributes: options.fetch(
            :expected_attributes,
            options[:expected_attributes_on_failure]
          ),
          invalid_attributes:,
          params:              configured_params,
          &should_not_update_the_entity
        )

        include_contract(
          'should update the entity',
          existing_entity:,
          expected_attributes: options.fetch(
            :expected_attributes,
            options[:expected_attributes_on_success]
          ),
          expected_value:      options[:expected_value_on_success],
          valid_attributes:,
          params:              configured_params,
          &options[:examples_on_success]
        )
      end
    end

    # Contract asserting the action updates the entity.
    module ShouldUpdateTheEntityContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, existing_entity:, valid_attributes:, **options)
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

          context 'with valid parameters' do
            let(:request) do
              Cuprum::Rails::Request.new(params: configured_params)
            end
            let(:configured_params) do
              Cuprum::Rails::RSpec::Contracts::Actions::UpdateContracts
                .parameters(
                  context:          self,
                  existing_entity:,
                  resource:         configured_resource,
                  valid_attributes:,
                  **options
                )
            end
            let(:configured_existing_entity) do
              option_with_default(existing_entity)
            end
            let(:configured_valid_attributes) do
              option_with_default(valid_attributes)
            end
            let(:configured_expected_attributes) do
              existing_attributes =
                configured_existing_entity
                  .attributes
                  .tap { |hsh| hsh.delete('updated_at') }

              option_with_default(
                options[:expected_attributes],
                default: existing_attributes.merge(configured_valid_attributes)
              )
            end
            let(:configured_expected_entity) do
              configured_resource
                .entity_class
                .find(
                  configured_existing_entity[configured_resource.primary_key]
                )
            end
            let(:configured_expected_value) do
              resource_name = configured_resource.singular_name

              option_with_default(
                options[:expected_value],
                default: {
                  resource_name => configured_expected_entity
                }
              )
            end

            it 'should return a passing result' do
              expect(call_action)
                .to be_a_passing_result
                .with_value(configured_expected_value)
            end

            it 'should update the entity' do
              expect { call_action }
                .to(
                  change do
                    configured_existing_entity
                      .reload
                      .attributes
                      .tap { |hsh| hsh.delete('updated_at') }
                  end
                  .to(be >= configured_expected_attributes)
                )
            end

            instance_exec(&block) if block
          end
        end
      end
    end
  end
end
