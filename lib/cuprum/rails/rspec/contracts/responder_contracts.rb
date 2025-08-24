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
        SleepingKingStudios::Tools::Toolbelt
          .instance
          .core_tools
          .deprecate(
            'Cuprum::Rails::RSpec::Contracts::ResponderContracts',
            'Use Cuprum::Rails::RSpec::Deferred::ResponderExamples instead.'
          )

        def self.let?(method_name, &block)
          let(method_name, &block) unless method_defined?(method_name)
        end

        let?(:resource_options) { { name: 'books' } }
        let?(:resource) do
          Cuprum::Rails::Resource.new(**resource_options)
        end

        example_class(controller_name) do |klass|
          configured_resource = resource

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

        describe '#routes' do
          include_examples 'should define reader', :routes

          let(:resource_options) { super().merge(name: 'books') }

          it 'should return the resource routes' do
            expect(responder.routes)
              .to be_a Cuprum::Rails::Routing::PluralRoutes
          end

          it { expect(responder.routes.base_path).to be == '/books' }

          it { expect(responder.routes.index_path).to be == '/books' }

          it { expect(responder.routes.parent_path).to be == '/' }

          it { expect(responder.routes.show_path(0)).to be == '/books/0' }

          it { expect(responder.routes.wildcards).to be == {} }

          context 'when the request has path params' do
            let(:path_params) { { 'author_id' => 0 } }
            let(:request) do
              Cuprum::Rails::Request.new(path_params:)
            end

            it { expect(responder.routes.wildcards).to be == path_params }
          end

          context 'when initialized with a singular resource' do
            let(:resource_options) do
              super().merge(name: 'book', singular: true)
            end

            it 'should return the resource routes' do
              expect(responder.routes)
                .to be_a Cuprum::Rails::Routing::SingularRoutes
            end

            it { expect(responder.routes.base_path).to be == '/book' }

            it { expect(responder.routes.show_path).to be == '/book' }
          end

          context 'when initialized with a resource with custom routes' do
            let(:resource_options) do
              super().merge(
                routes: Cuprum::Rails::Routes.new(base_path: '/path/to/books')
              )
            end

            it { expect(responder.routes.base_path).to be == '/path/to/books' }
          end

          context 'when initialized with a resource with ancestors' do
            let(:base_path) { '/authors/:author_id/series/:series_id' }
            let(:authors_resource) do
              Cuprum::Rails::Resource.new(name: 'authors')
            end
            let(:series_resource) do
              Cuprum::Rails::Resource.new(
                name:          'series',
                singular_name: 'series',
                parent:        authors_resource
              )
            end
            let(:resource_options) { super().merge(parent: series_resource) }

            it 'should set the scoped base path' do
              expect(responder.routes.base_path).to be == "#{base_path}/books"
            end

            context 'when the request has path params' do
              let(:path_params) { { 'author_id' => 0, 'series_id' => 1 } }
              let(:parent_path) { '/authors/0/series/1' }
              let(:request) do
                Cuprum::Rails::Request.new(path_params:)
              end

              it { expect(responder.routes.wildcards).to be == path_params }

              it 'should set the scoped index path' do
                expect(responder.routes.index_path)
                  .to be == "#{parent_path}/books"
              end

              it 'should set the scoped parent path' do
                expect(responder.routes.parent_path)
                  .to be == parent_path
              end

              it 'should set the scoped show path' do
                expect(responder.routes.show_path(2))
                  .to be == "#{parent_path}/books/2"
              end
            end
          end
        end
      end
    end
  end
end
