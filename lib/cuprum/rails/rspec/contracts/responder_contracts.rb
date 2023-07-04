# frozen_string_literal: true

require 'rspec/sleeping_king_studios/contract'

require 'cuprum/rails/rspec/contracts'

module Cuprum::Rails::RSpec::Contracts
  # Namespace for RSpec responder contracts.
  module ResponderContracts
    # Contract validating the interface for a responder.
    module ShouldImplementTheResponderMethodsContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, constructor_keywords: [])
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      #   @param constructor_keywords [Array<Symbol>] additional keywords that
      #     are required by the constructor.
      #   @param controller_name [String] the name of the test controller.
      contract do |
        constructor_keywords: [],
        controller_name:      'Spec::CustomController'
      |
        example_class(controller_name) do |klass|
          configured_resource =
            if defined?(resource)
              resource
            else
              Cuprum::Rails::Resource.new(resource_name: 'books')
            end

          klass.define_singleton_method(:resource) do
            @resource ||= configured_resource
          end
        end

        describe '.new' do
          let(:expected_keywords) do
            %i[
              action_name
              controller
              member_action
              request
              resource
            ]
          end

          it 'should define the constructor' do
            expect(described_class)
              .to respond_to(:new)
              .with(0).arguments
              .and_keywords(*expected_keywords, *constructor_keywords)
              .and_any_keywords
          end
        end

        describe '#action_name' do
          include_examples 'should define reader',
            :action_name,
            -> { action_name }
        end

        describe '#call' do
          let(:result) { Cuprum::Result.new(value: :ok) }

          def ignore_exceptions
            yield
          rescue StandardError
            # Do nothing
          end

          it { expect(responder).to respond_to(:call).with(1).argument }

          it 'should set the result' do
            expect { ignore_exceptions { responder.call(result) } }
              .to change(responder, :result)
              .to be == result
          end
        end

        describe '#controller' do
          include_examples 'should define reader',
            :controller,
            -> { controller }
        end

        describe '#controller_name' do
          include_examples 'should define reader',
            :controller_name,
            controller_name
        end

        describe '#member_action?' do
          include_examples 'should define predicate',
            :member_action?,
            -> { !!constructor_options[:member_action] } # rubocop:disable Style/DoubleNegation

          context 'when initialized with member_action: false' do
            let(:constructor_options) { super().merge(member_action: false) }

            it { expect(responder.member_action?).to be false }
          end

          context 'when initialized with member_action: true' do
            let(:constructor_options) { super().merge(member_action: true) }

            it { expect(responder.member_action?).to be true }
          end
        end

        describe '#request' do
          include_examples 'should define reader', :request, -> { request }
        end

        describe '#resource' do
          include_examples 'should define reader',
            :resource,
            -> { controller.class.resource }
        end

        describe '#result' do
          include_examples 'should define reader', :result, nil
        end
      end
    end
  end
end
