# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred/provider'

require 'cuprum/rails/rspec/deferred/commands/resources'
require 'cuprum/rails/rspec/deferred/commands/resources_examples'

module Cuprum::Rails::RSpec::Deferred::Commands::Resources
  # Deferred examples for validating Show command implementations.
  module ShowExamples
    include RSpec::SleepingKingStudios::Deferred::Provider
    include Cuprum::Rails::RSpec::Deferred::Commands::ResourcesExamples

    # Examples that assert that the command returns the expected entity.
    #
    # The following methods must be defined in the example group:
    #
    # - #call_command: A method that calls the command being tested with all
    #   required parameters.
    # - #expected_value: The value returned by the command.
    deferred_examples 'should find the entity' do
      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_value)
      end
    end

    # Examples that assert the command implements the New contract.
    #
    # To access the actual entity for each case, call #matched_entity.
    #
    # The behavior can be customized by defining the following methods:
    #
    # - #expected_value: The value returned by the command. Defaults to the
    #   matched entity.
    # - #entity: The entity directly passed to the command. Defaults to the
    #   first item in the fixtures.
    # - #valid_primary_key_value: The value for the primary key for an unscoped
    #   collection. Defaults to the primary key value for the first item in the
    #   fixtures.
    # - #valid_scoped_primary_key_value: The value for the primary key for a
    #   scoped collection. Defaults to the primary key value for the first item
    #   in the collection that matches #resource_scope.
    deferred_examples 'should implement the Show command' \
    do |**examples_opts, &block|
      describe '#call' do
        define_method :call_command do
          return super() if defined?(super())

          command.call(entity:, primary_key:)
        end

        it 'should define the method' do
          expect(command)
            .to be_callable
            .with(0).arguments
            .and_keywords(:entity, :primary_key)
            .and_any_keywords
        end

        include_deferred('should require entity', **examples_opts)

        include_deferred('with a valid entity', **examples_opts) do
          include_deferred 'should find the entity'
        end

        instance_exec(&block) if block
      end
    end
  end
end
