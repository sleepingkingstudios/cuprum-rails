# frozen_string_literal: true

require 'rspec/sleeping_king_studios/contract'

require 'cuprum/rails/rspec/contract_helpers'
require 'cuprum/rails/rspec/contracts/action_contracts'
require 'cuprum/rails/rspec/contracts/actions'

module Cuprum::Rails::RSpec::Contracts::Actions
  # Namespace for RSpec new contracts, which validate new implementations.
  module NewContracts
    # Contract asserting the action implements the new action interface.
    module ShouldBeANewActionContract
      extend RSpec::SleepingKingStudios::Contract

      # @method apply(example_group, **options, &block)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] The example group to
      #     which the contract is applied.
      #
      #   @option options [Hash<String>] expected_attributes_on_success The
      #     expected attributes for the returned object. Defaults to the value
      #     of valid_attributes.
      #   @option options [Hash<String>] expected_value_on_success The expected
      #     value for the passing result. Defaults to a Hash with the created
      #     entity.
      #   @option options [#to_proc] examples_on_success Extra examples to run
      #     for the passing case.
      #
      #   @yield Additional examples to run for the passing case.
      contract do |**options, &block|
        include Cuprum::Rails::RSpec::Contracts::ActionContracts
        include Cuprum::Rails::RSpec::Contracts::Actions::NewContracts

        # :nocov:
        if options[:examples_on_success] && block
          raise ArgumentError, 'provide either :examples_on_success or a block'
        elsif block
          options[:examples_on_success] = block
        end
        # :nocov:

        include_contract 'should be a resource action'

        include_contract(
          'should build the entity',
          expected_attributes: options[:expected_attributes_on_success],
          expected_value:      options[:expected_value_on_success],
          &options[:examples_on_success]
        )
      end
    end

    # Contract asserting the action builds a new entity.
    module ShouldBuildTheEntityContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, **options)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] The example group to
      #     which the contract is applied.
      #
      #   @option options [Hash<String>] expected_attributes The expected
      #     attributes for the returned object.
      #   @option options [Hash<String>] expected_value The expected value for
      #     the passing result. Defaults to a Hash with the built entity.
      #   @option options [Hash<String>] params The parameters used to build the
      #     request. Defaults to the id of the entity and the given attributes.
      #
      #   @yield Additional examples.
      contract do |**options, &block|
        describe '#call' do
          include Cuprum::Rails::RSpec::ContractHelpers

          let(:request) do
            Cuprum::Rails::Request.new(params: configured_params)
          end
          let(:configured_params) do
            option_with_default(options[:params], default: {})
          end
          let(:configured_expected_attributes) do
            option_with_default(options[:expected_attributes], default: {})
          end
          let(:configured_expected_entity) do
            configured_resource
              .entity_class
              .new(configured_expected_attributes)
          end
          let(:configured_expected_value) do
            resource_name = configured_resource.singular_name

            option_with_default(
              options[:expected_value],
              default: { resource_name => configured_expected_entity }
            )
          end

          it 'should return a passing result' do
            expect(call_action)
              .to be_a_passing_result
              .with_value(configured_expected_value)
          end

          instance_exec(&block) if block
        end
      end
    end
  end
end
