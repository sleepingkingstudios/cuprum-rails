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
      #   @option options [#to_proc] examples_on_failure Extra examples to run
      #     for the failing cases.
      #   @option options [#to_proc] examples_on_success Extra examples to run
      #     for the passing case.
      #   @option options [Hash<String>] expected_attributes The expected
      #     attributes for both a failed validation and a returned entity.
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
      #
      #   @yield Additional examples to run for the passing case.

      contract do |invalid_attributes:, valid_attributes:, **options, &block|
        include Cuprum::Rails::RSpec::ActionsContracts
        include Cuprum::Rails::RSpec::Actions::CreateContracts

        options = options.merge(valid_attributes: valid_attributes)
        configured_params = lambda do
          attributes =
            Cuprum::Rails::RSpec::ContractHelpers.option_with_default(
              valid_attributes,
              context: self
            )

          Cuprum::Rails::RSpec::ContractHelpers.option_with_default(
            options[:params],
            context: self,
            default: {
              action.resource.singular_resource_name => attributes
            }
          )
        end

        # :nocov:
        if options[:examples_on_success] && block # rubocop:disable Style/GuardClause
          raise ArgumentError, 'provide either :examples_on_success or a block'
        elsif block
          options[:examples_on_success] = block
        end

        # :nocov:

        should_not_create_an_entity = lambda do
          it 'should not create an entity' do
            expect { action.call(request: request) }
              .not_to change(action.resource.resource_class, :count)
          end

          # :nocov:
          if options[:examples_on_failure]
            instance_exec(&options[:examples_on_failure])
          end
          # :nocov:
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
          expected_attributes: options.fetch(
            :expected_attributes,
            options[:expected_attributes_on_failure]
          ),
          invalid_attributes:  invalid_attributes,
          params:              configured_params,
          &should_not_create_an_entity
        )

        if options[:duplicate_attributes]
          include_contract(
            'should not create a duplicate entity',
            params:           configured_params,
            valid_attributes: options[:duplicate_attributes],
            &should_not_create_an_entity
          )
        end

        include_contract 'should create the entity',
          expected_attributes: options.fetch(
            :expected_attributes,
            options[:expected_attributes_on_success]
          ),
          expected_value:      options[:expected_value_on_success],
          params:              configured_params,
          valid_attributes:    valid_attributes,
          &options[:examples_on_success]
      end
    end

    # Contract asserting the action creates a new entity.
    module ShouldCreateTheEntityContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, valid_attributes:, **options)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] The example group to
      #     which the contract is applied.
      #
      #   @option options [Hash<String>] expected_attributes The expected
      #     attributes for the returned object. Defaults to the value of
      #     valid_attributes.
      #   @option options [Hash<String>] expected_value The expected value for
      #     the passing result. Defaults to a Hash with the created entity.
      #   @option options [Hash<String>] params The parameters used to build the
      #     request. Defaults to the given attributes.
      #   @option options [Hash<String>] valid_attributes A set of attributes
      #     that will pass validation.
      #
      #   @yield Additional examples.

      contract do |valid_attributes:, **options, &block|
        describe '#call' do
          include Cuprum::Rails::RSpec::ContractHelpers

          context 'with valid parameters' do
            let(:request) do
              instance_double(Cuprum::Rails::Request, params: configured_params)
            end
            let(:configured_valid_attributes) do
              option_with_default(valid_attributes)
            end
            let(:configured_params) do
              resource_name = resource.singular_resource_name

              option_with_default(
                options[:params],
                default: {}
              )
                .merge({ resource_name => configured_valid_attributes })
            end
            let(:configured_expected_attributes) do
              option_with_default(
                options[:expected_attributes],
                default: configured_valid_attributes
              )
            end
            let(:configured_expected_entity) do
              action
                .resource
                .resource_class
                .where(configured_expected_attributes)
                .first
            end
            let(:configured_expected_value) do
              resource_name = resource.singular_resource_name

              option_with_default(
                options[:expected_value],
                default: {
                  resource_name => configured_expected_entity
                }
              )
            end

            it 'should return a passing result' do
              expect(action.call(request: request))
                .to be_a_passing_result
                .with_value(configured_expected_value)
            end

            it 'should create the entity', :aggregate_failures do
              expect { action.call(request: request) }
                .to change(action.resource.resource_class, :count)
                .by(1)

              expect(
                action
                  .resource
                  .resource_class
                  .where(configured_expected_attributes)
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
      #
      #   @option options [Hash<String>] params The parameters used to build the
      #     request. Defaults to the given attributes.
      #
      #   @yield Additional examples.

      contract do |valid_attributes:, **options, &block|
        describe '#call' do
          include Cuprum::Rails::RSpec::ContractHelpers

          context 'with duplicate parameters' do
            let(:request) do
              instance_double(Cuprum::Rails::Request, params: configured_params)
            end
            let(:configured_valid_attributes) do
              option_with_default(valid_attributes)
            end
            let(:configured_duplicate_entity) do
              action.resource.resource_class.new(valid_attributes)
            end
            let(:configured_params) do
              resource_name = action.resource.singular_resource_name

              option_with_default(
                options[:params],
                default: {}
              )
                .merge({ resource_name => configured_valid_attributes })
            end
            let(:configured_expected_error) do
              primary_key_name  = action.resource.primary_key.intern
              primary_key_value = configured_duplicate_entity[primary_key_name]

              Cuprum::Collections::Errors::AlreadyExists.new(
                attribute_name:  primary_key_name,
                attribute_value: primary_key_value,
                collection_name: action.resource.resource_name,
                primary_key:     true
              )
            end

            before(:example) { configured_duplicate_entity.save! }

            it 'should return a failing result' do
              expect(action.call(request: request))
                .to be_a_failing_result
                .with_error(configured_expected_error)
            end

            instance_exec(&block) if block.is_a?(Proc)
          end
        end
      end
    end
  end
end
