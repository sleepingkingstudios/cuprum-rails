# frozen_string_literal: true

require 'cuprum/collections/rspec/fixtures'
require 'rspec/sleeping_king_studios/deferred'

require 'cuprum/rails/rspec/deferred'
require 'cuprum/rails/rspec/deferred/controllers/middleware_matcher'

module Cuprum::Rails::RSpec::Deferred
  # Deferred examples for validating resource command implementations.
  module ControllerExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    # Asserts that the controller defines the specified action.
    #
    # @param action_name [String, Symbol] the name of the action.
    # @param action_class [Class] the class of the action.
    # @param command_class [Class] the expected class of the wrapped command,
    #   if any.
    # @param member [true, false] true if the expected action is a member
    #   action, otherwise false.
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

    # rubocop:disable Metrics/ParameterLists

    # Asserts that the controller defines the specified middleware.
    #
    # Finds any defined middleware with the specified class. Then, verifies that
    # at least one of the defined middleware matches the remaining constraints:
    # actions, formats, and additional matchers, if any.
    #
    # @param middleware_class [Class] the class of the expected middleware.
    # @param actions [Hash, Array<String, Symbol>, String, Symbol] the expected
    #   actions allowed for the middleware. Defaults to [] (all actions).
    # @param formats [Hash, Array<String, Symbol>, String, Symbol] the expected
    #   formats allowed for the middleware. Defaults to [] (all formats).
    # @param matching [RSpec::Core::Matcher, Hash] if present, verifies that the
    #   middleware matches the given matcher or has the given attributes.
    deferred_examples 'should define middleware' \
    do |
      middleware_class,
      actions:  [],
      except:   [],
      formats:  [],
      matching: nil,
      only:     []
    |
      # rubocop:enable Metrics/ParameterLists
      describe '.middleware' do
        matcher_class =
          Cuprum::Rails::RSpec::Deferred::Controllers::MiddlewareMatcher

        # :nocov:
        let(:configured_class) do
          # @deprecate 0.3.0
          next middleware_class unless middleware_class.is_a?(Proc)

          instance_exec(&middleware_class)
        end
        let(:configured_matching) do
          next matching unless matching.is_a?(Proc)

          instance_exec(&matching)
        end
        let(:expected_options) do
          matcher_class::Options.new(
            actions:,
            except:,
            formats:,
            matching:         configured_matching,
            middleware_class: configured_class,
            only:
          )
        end
        # :nocov:

        example_description =
          if middleware_class.is_a?(Class)
            "should define middleware #{middleware_class.name}"
          else
            # :nocov:

            # @deprecate 0.3.0
            'should define the middleware'
            # :nocov:
          end

        it(example_description) do
          define_middleware = matcher_class.new(expected_options)

          expect(described_class).to define_middleware
        end
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
