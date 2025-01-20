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

    deferred_examples 'should destroy the entity' do
      before(:example) { expected_entity }

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_entity)
      end

      it { expect { call_command }.to change { persisted_data.count }.by(-1) }

      it 'should remove the entity from the collection' do
        primary_key_value = primary_key_for(expected_entity)

        expect { call_command }.to(
          change { persisted_data }.to(
            satisfy do |data|
              data.none? { |item| primary_key_for(item) == primary_key_value }
            end
          )
        )
      end
    end

    deferred_examples 'should implement the Destroy command' \
    do |**examples_opts|
      describe '#call' do
        def call_command
          return super if defined?(super)

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
      end
    end
  end
end
