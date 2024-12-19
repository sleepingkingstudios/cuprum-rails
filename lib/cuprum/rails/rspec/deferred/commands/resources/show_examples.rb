# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred/provider'

require 'cuprum/rails/rspec/deferred/commands/resources'
require 'cuprum/rails/rspec/deferred/commands/resources_examples'

module Cuprum::Rails::RSpec::Deferred::Commands::Resources
  # Deferred examples for validating Show command implementations.
  module ShowExamples
    include RSpec::SleepingKingStudios::Deferred::Provider
    include Cuprum::Rails::RSpec::Deferred::Commands::ResourcesExamples

    deferred_examples 'should find the entity' do
      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_entity)
      end
    end

    deferred_examples 'should implement the Show command' do |**examples_opts|
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
          include_deferred 'should find the entity'
        end
      end
    end
  end
end
