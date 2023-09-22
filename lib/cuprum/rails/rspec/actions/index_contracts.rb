# frozen_string_literal: true

require 'cuprum/rails/rspec/actions'
require 'cuprum/rails/rspec/actions_contracts'

module Cuprum::Rails::RSpec::Actions
  # Namespace for RSpec index contracts, which validate index implementations.
  module IndexContracts
    # Contract asserting the action implements the index action interface.
    module IndexActionContract
      extend RSpec::SleepingKingStudios::Contract

      # @method apply(example_group, existing_entities:, **options)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] The example group to
      #     which the contract is applied.
      #   @param existing_entities [Object] The existing entities to find.
      #
      #   @option options [#to_proc] examples_on_success Extra examples to run
      #     for the passing case.
      #   @option options [Hash<String>] expected_value_on_success The expected
      #     value for the passing result. Defaults to a Hash with the found
      #     entity.
      #   @option options [Hash<String>] params The parameters used to build the
      #     request. Defaults to an empty hash.
      #
      #   @yield Additional examples to run for the passing case.

      contract do |existing_entities:, **options, &block|
        include Cuprum::Rails::RSpec::ActionsContracts
        include Cuprum::Rails::RSpec::Actions::IndexContracts

        # :nocov:
        if options[:examples_on_success] && block
          raise ArgumentError, 'provide either :examples_on_success or a block'
        elsif block
          options[:examples_on_success] = block
        end
        # :nocov:

        include_contract 'resource action contract'

        include_contract 'should find the entities',
          existing_entities: existing_entities,
          expected_value:    options[:expected_value_on_success],
          params:            options[:params],
          &options[:examples_on_success]
      end
    end

    # Contract asserting the action queries the repository for the entities.
    module ShouldFindTheEntitiesContract
      extend RSpec::SleepingKingStudios::Contract

      # @method apply(example_group, existing_entities:, **options)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] The example group to
      #     which the contract is applied.
      #   @param existing_entities [Object] The existing entities to find.
      #
      #   @option options [Hash<String>] expected_value The expected
      #     value for the passing result. Defaults to a Hash with the found
      #     entity.
      #   @option options [Hash<String>] params The parameters used to build the
      #     request. Defaults to an empty hash.
      #
      #   @yield Additional examples.

      contract do |existing_entities:, **options, &block|
        include Cuprum::Rails::RSpec::ActionsContracts

        describe '#call' do
          include Cuprum::Rails::RSpec::ContractHelpers

          let(:request) do
            Cuprum::Rails::Request.new(params: configured_params)
          end
          let(:configured_params) do
            option_with_default(options[:params], default: {})
          end
          let(:configured_existing_entities) do
            option_with_default(existing_entities)
          end
          let(:configured_expected_value) do
            resource_name = configured_resource.resource_name

            option_with_default(
              options[:expected_value],
              default: {
                resource_name => configured_existing_entities
              }
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
