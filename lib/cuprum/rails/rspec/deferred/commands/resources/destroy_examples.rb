# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred/provider'

require 'cuprum/rails/rspec/deferred/commands/resources'
require 'cuprum/rails/rspec/deferred/commands/resources_examples'

module Cuprum::Rails::RSpec::Deferred::Commands::Resources
  # Deferred examples for validating Destroy command implementations.
  module DestroyExamples
    include RSpec::SleepingKingStudios::Deferred::Provider
    include Cuprum::Rails::RSpec::Deferred::Commands::ResourcesExamples

    define_method :persisted_data do
      return super if defined?(super)

      repository[resource.qualified_name]
        .find_matching
        .call
        .value
        .to_a
    end

    define_method :primary_key_for do |entity|
      entity[resource.primary_key_name]
    end

    # Examples that assert that the command destroys the entity.
    #
    # The following examples are defined:
    #
    # - The command should return a passing result, with the result value equal
    #   to the removed entity.
    # - Calling the command should decrement the collection count by -1.
    # - After calling the command, the collection should not include any items
    #   whose attributes match the destroyed entity's attributes.
    #
    # The following methods must be defined in the example group:
    #
    # - #call_command: A method that calls the command being tested with all
    #   required parameters.
    #
    # The behavior can be customized by defining the following methods:
    #
    # - #expected_value: The value returned by a successful call. Defaults to
    #   the destroyed entity.
    deferred_examples 'should destroy the entity' do
      include RSpec::SleepingKingStudios::Deferred::Dependencies

      depends_on :call_command,
        'method that calls the command being tested with required parameters'

      before(:example) { expected_value }

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_value)
      end

      it { expect { call_command }.to change { persisted_data.count }.by(-1) } # rubocop:disable RSpec/ExpectChange

      it 'should remove the entity from the collection' do # rubocop:disable RSpec/ExampleLength
        primary_key_value = primary_key_for(expected_value)

        expect { call_command }.to(
          change { persisted_data }.to(
            satisfy do |data|
              data.none? { |item| primary_key_for(item) == primary_key_value }
            end
          )
        )
      end
    end

    # Exampels that assert the command implements the Destroy contract.
    #
    # To access the actual entity for each case, call #matched_entity.
    deferred_examples 'should implement the Destroy command' \
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
          include_deferred 'should destroy the entity'
        end

        instance_exec(&block) if block
      end
    end
  end
end
