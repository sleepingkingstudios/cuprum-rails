# frozen_string_literal: true

require 'cuprum/collections/rspec/fixtures'
require 'rspec/sleeping_king_studios/deferred'

require 'cuprum/rails/rspec/deferred'

module Cuprum::Rails::RSpec::Deferred
  # Deferred examples for validating resource command implementations.
  module ControllerExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_examples 'should define action' \
    do |action_name, action_class, command_class: nil, member: nil|
      describe "##{action_name}" do
        it 'should define the action', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
          expect(subject).to respond_to(action_name)

          expect(described_class.actions).to have_key(action_name.intern)

          action = described_class.actions[action_name.intern]

          expect(action.action_class).to be <= action_class

          if command_class
            expect(action.action_class.new.command_class).to be <= command_class
          end

          expect(action.member_action?).to be member unless member.nil?
        end
      end
    end

    deferred_examples 'should define middleware' \
    do |expected, except: [], only: []|
      describe '.middleware' do
        let(:middleware) do
          described_class
            .middleware
            .find { |config| match_middleware(expected, config) }
        end

        def match_middleware(expected, actual)
          expected = instance_exec(&expected) if expected.is_a?(Proc)

          if expected.is_a?(Class)
            return true if actual.command == expected
            return true if actual.command.is_a?(expected)
          end

          if expected.respond_to?(:matches?)
            return expected.matches?(actual.command)
          end

          actual.command == expected
        end

        it 'should define the middleware' do
          expect(described_class.middleware).to include(
            satisfy { |actual| match_middleware(expected, actual) }
          )
        end

        it { expect(middleware.except.to_a).to be == except }

        it { expect(middleware.only.to_a).to be == only }
      end
    end

    deferred_examples 'should not respond to format' do |format|
      it { expect(described_class.responders[format.intern]).to be nil }
    end

    deferred_examples 'should respond to format' do |format, using:|
      it { expect(described_class.responders[format.intern]).to be == using }
    end
  end
end
