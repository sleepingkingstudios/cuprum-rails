# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred/provider'

require 'cuprum/rails/rspec/deferred/commands/resources'
require 'cuprum/rails/rspec/deferred/commands/resources_examples'

module Cuprum::Rails::RSpec::Deferred::Commands::Resources
  # Deferred examples for validating Show command implementations.
  module ShowExamples
    include RSpec::SleepingKingStudios::Deferred::Provider
    include Cuprum::Rails::RSpec::Deferred::Commands::ResourcesExamples

    deferred_examples 'should implement the Show command' do |**examples_opts|
      describe '#call' do
        def call_command
          command.call(entity:, primary_key:)
        end

        include_deferred('should require entity', **examples_opts)
      end
    end
  end
end
