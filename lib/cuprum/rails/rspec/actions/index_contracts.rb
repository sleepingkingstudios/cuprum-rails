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
      #   @option options [Hash<String>] expected_value_on_success The expected
      #     value for the passing result. Defaults to a Hash with the found
      #     entity.

      contract do |existing_entities:, **options|
        include Cuprum::Rails::RSpec::ActionsContracts
        include Cuprum::Rails::RSpec::Actions::IndexContracts

        include_contract 'resource action contract'

        include_contract 'should find the entities',
          existing_entities: existing_entities,
          expected_value:    options[:expected_value_on_success]
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

      contract do |existing_entities:, **contract_options|
        include Cuprum::Rails::RSpec::ActionsContracts

        contract_options =
          contract_options.merge(existing_entities: existing_entities)

        describe '#call' do
          include Cuprum::Rails::RSpec::ContractHelpers

          let(:params) do
            defined?(super()) ? super() : {}
          end
          let(:request) do
            instance_double(Cuprum::Rails::Request, params: params)
          end
          let(:existing_entities) do
            option_with_default(
              configured: contract_options[:existing_entities],
              context:    self
            )
          end
          let(:expected_value) do
            option_with_default(
              configured: contract_options[:expected_value],
              context:    self,
              default:    {
                action.resource.resource_name => self.existing_entities
              }
            )
          end

          it 'should return a passing result' do
            expect(action.call(request: request))
              .to be_a_passing_result
              .with_value(expected_value)
          end
        end
      end
    end
  end
end
