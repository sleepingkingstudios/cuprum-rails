# frozen_string_literal: true

require 'rspec/sleeping_king_studios/contract'

require 'cuprum/rails/rspec/actions'
require 'cuprum/rails/rspec/actions_contracts'
require 'cuprum/rails/rspec/contract_helpers'

module Cuprum::Rails::RSpec::Actions
  # Namespace for RSpec create contracts, which validate create implementations.
  module CreateContracts
    # Contract asserting the action implements the create action interface.
    module CreateActionContract
      extend RSpec::SleepingKingStudios::Contract

      # @method apply(example_group, invalid_attributes:, valid_attributes:, **options) # rubocop:disable Layout/LineLength
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] The example group to
      #     which the contract is applied.
      #   @param invalid_attributes [Hash<String>] A set of attributes that will
      #     fail validation.
      #   @param valid_attributes [Hash<String>] A set of attributes that will
      #     pass validation.
      #
      #   @option options [Hash<String>] duplicate_attributes A set of
      #     attributes for a duplicate entity.
      #   @option options [Hash<String>] expected_attributes_on_failure The
      #     expected attributes for a failed validation. Defaults to the value
      #     of invalid_attributes.
      #   @option options [Hash<String>] expected_attributes_on_success The
      #     expected attributes for the returned object. Defaults to the value
      #     of valid_attributes.
      #   @option options [Hash<String>] expected_value_on_success The expected
      #     value for the passing result. Defaults to a Hash with the created
      #     entity.
      #   @option options [Hash<String>] params The parameters used to build the
      #     request. Defaults to the given attributes.
      #   @option options [#to_proc] examples_on_success Extra examples to run
      #     for the passing case.

      contract do |invalid_attributes:, valid_attributes:, **options|
        include Cuprum::Rails::RSpec::ActionsContracts
        include Cuprum::Rails::RSpec::Actions::CreateContracts

        options = options.merge(valid_attributes: valid_attributes)
        configured_params = lambda do
          attributes =
            Cuprum::Rails::RSpec::ContractHelpers.option_with_default(
              configured: valid_attributes,
              context:    self
            )

          Cuprum::Rails::RSpec::ContractHelpers.option_with_default(
            configured: options[:params],
            context:    self,
            default:    {
              action.resource.singular_resource_name => attributes
            }
          )
        end

        should_not_create_an_entity = lambda do
          it 'should not create an entity' do
            expect { action.call(request: request) }
              .not_to change(action.resource.resource_class, :count)
          end
        end

        include_contract 'resource action contract'

        include_contract(
          'should require permitted attributes',
          params: configured_params,
          &should_not_create_an_entity
        )

        include_contract(
          'should require parameters',
          params: configured_params,
          &should_not_create_an_entity
        )

        include_contract(
          'should validate attributes',
          expected_attributes: options[:expected_attributes_on_failure],
          invalid_attributes:  invalid_attributes,
          params:              configured_params,
          &should_not_create_an_entity
        )

        if options[:duplicate_attributes]
          include_contract 'should not create a duplicate entity',
            valid_attributes: options[:duplicate_attributes]
        end

        include_contract 'should create the entity',
          expected_attributes: options[:expected_attributes_on_success],
          expected_value:      options[:expected_value_on_success],
          valid_attributes:    valid_attributes,
          &options[:examples_on_success]
      end
    end

    # Contract asserting the action creates a new entity.
    module ShouldCreateTheEntityContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, valid_attributes:, expected_attributes: nil, expected_value: nil) # rubocop:disable Layout/LineLength
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] The example group to
      #     which the contract is applied.
      #   @param valid_attributes [Hash<String>] A set of attributes that will
      #     pass validation.
      #   @param expected_attributes [Hash<String>] The expected attributes for
      #     the returned object. Defaults to the value of valid_attributes.
      #   @param expected_value [Hash<String>] The expected value for the
      #     passing result. Defaults to a Hash with the created entity.
      #
      #   @yield Additional examples.

      contract do |valid_attributes:, **contract_options, &block|
        contract_options.update(valid_attributes: valid_attributes)

        describe '#call' do
          include Cuprum::Rails::RSpec::ContractHelpers

          let(:params) do
            defined?(super()) ? super() : {}
          end
          let(:request) do
            instance_double(Cuprum::Rails::Request, params: params)
          end

          context 'with valid parameters' do
            let(:valid_attributes) do
              option_with_default(
                configured: valid_attributes,
                context:    self
              )
            end
            let(:expected_attributes) do
              option_with_default(
                configured: contract_options[:expected_attributes],
                context:    self,
                default:    self.valid_attributes
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
                .where(expected_attributes)
                .first
            end
            let(:expected_value) do
              option_with_default(
                configured: contract_options[:expected_value],
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

            it 'should create the entity', :aggregate_failures do
              expect { action.call(request: request) }
                .to change(action.resource.resource_class, :count)
                .by(1)

              expect(
                action
                  .resource
                  .resource_class
                  .where(expected_attributes)
                  .exists?
              ).to be true
            end

            instance_exec(&block) if block.is_a?(Proc)
          end
        end
      end
    end

    # Contract asserting the action does not create a duplicate entity.
    module ShouldNotCreateADuplicateEntityContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, valid_attributes:, primary_key: :id)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] The example group to
      #     which the contract is applied.
      #   @param valid_attributes [Hash<String>] A set of attributes that will
      #     pass validation.
      #   @param primary_key [Symbol] The name of the primary key attribute.

      contract do |valid_attributes:, primary_key: :id, **contract_options|
        contract_options.update(
          primary_key:      primary_key,
          valid_attributes: valid_attributes
        )

        describe '#call' do
          let(:duplicate_entity) do
            action.resource.resource_class.new(valid_attributes)
          end
          let(:params) do
            defined?(super()) ? super() : {}
          end
          let(:request) do
            instance_double(Cuprum::Rails::Request, params: params)
          end

          before(:example) do
            duplicate_entity.save!
          end

          context 'with duplicate parameters' do
            let(:params) do
              super().merge({
                action.resource.singular_resource_name => valid_attributes
              })
            end
            let(:expected_error) do
              primary_key_name  = resource.primary_key.intern
              primary_key_value = duplicate_entity[primary_key_name]

              Cuprum::Collections::Errors::AlreadyExists.new(
                collection_name:    action.resource.resource_name,
                primary_key_name:   primary_key_name,
                primary_key_values: primary_key_value
              )
            end

            it 'should not create the entity' do
              expect { action.call(request: request) }
                .not_to change(action.resource.resource_class, :count)
            end

            it 'should return a failing result' do
              expect(action.call(request: request))
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end
        end
      end
    end
  end
end
