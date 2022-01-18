# frozen_string_literal: true

require 'rspec/sleeping_king_studios/contract'

require 'cuprum/rails/rspec/actions'
require 'cuprum/rails/rspec/actions_contracts'
require 'cuprum/rails/rspec/contract_helpers'

module Cuprum::Rails::RSpec::Actions
  # Namespace for RSpec show contracts, which validate show implementations.
  module ShowContracts
    # Contract asserting the action implements the show action interface.
    module ShowActionContract
      extend RSpec::SleepingKingStudios::Contract

      # @method apply(example_group, existing_entity:, **options)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] The example group to
      #     which the contract is applied.
      #   @param existing_entity [Object] The existing entity to find.
      #
      #   @option options [#to_proc] examples_on_failure Extra examples to run
      #     for the failing cases.
      #   @option options [#to_proc] examples_on_success Extra examples to run
      #     for the passing case.
      #   @option options [Hash<String>] expected_value_on_success The expected
      #     value for the passing result. Defaults to a Hash with the found
      #     entity.
      #   @option options [Hash<String>] params The parameters used to build the
      #     request. Defaults to the id of the entity.
      #   @option options [Object] primary_key_value The value of the primary
      #     key for the missing entity.
      #
      #   @yield Additional examples to run for the passing case.

      contract do |existing_entity:, **options, &block|
        include Cuprum::Rails::RSpec::ActionsContracts

        # :nocov:
        if options[:examples_on_success] && block # rubocop:disable Style/GuardClause
          raise ArgumentError, 'provide either :examples_on_success or a block'
        elsif block
          options[:examples_on_success] = block
        end

        # :nocov:

        include_contract 'resource action contract'

        include_contract(
          'should require primary key',
          &options[:examples_on_failure]
        )

        include_contract(
          'should require existing entity',
          primary_key_value: options[:primary_key_value],
          &options[:examples_on_failure]
        )

        include_contract(
          'should find the entity',
          existing_entity: existing_entity,
          expected_value:  options[:expected_value_on_success],
          &options[:examples_on_success]
        )
      end
    end
  end
end
