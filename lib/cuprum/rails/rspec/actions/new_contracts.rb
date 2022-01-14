# frozen_string_literal: true

require 'rspec/sleeping_king_studios/contract'

require 'cuprum/rails/rspec/actions'
require 'cuprum/rails/rspec/actions_contracts'
require 'cuprum/rails/rspec/contract_helpers'

module Cuprum::Rails::RSpec::Actions
  # Namespace for RSpec new contracts, which validate new implementations.
  module NewContracts
    # Contract asserting the action implements the new action interface.
    module NewActionContract
      extend RSpec::SleepingKingStudios::Contract

      # @method apply(example_group, **options)
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
      contract do |**options|
        include Cuprum::Rails::RSpec::ActionsContracts
        include Cuprum::Rails::RSpec::Actions::NewContracts

        include_contract 'resource action contract'

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

      # @!method apply(example_group, expected_attributes: nil, expected_value: nil) # rubocop:disable Layout/LineLength
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] The example group to
      #     which the contract is applied.
      #   @param expected_attributes [Hash<String>] The expected attributes for
      #     the returned object.
      #   @param expected_value [Hash<String>] The expected value for the
      #     passing result. Defaults to a Hash with the built entity.
      #
      #   @yield Additional examples.
      contract do |**contract_options, &block|
        describe '#call' do
          include Cuprum::Rails::RSpec::ContractHelpers

          let(:params) do
            defined?(super()) ? super() : {}
          end
          let(:request) do
            instance_double(Cuprum::Rails::Request, params: params)
          end
          let(:expected_attributes) do
            option_with_default(
              configured: contract_options[:expected_attributes],
              context:    self,
              default:    {}
            )
          end
          let(:expected_entity) do
            action
              .resource
              .resource_class
              .new(expected_attributes)
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

          instance_exec(&block) if block
        end
      end
    end
  end
end
