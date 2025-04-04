# frozen_string_literal: true

require 'cuprum/collections/basic/repository'
require 'cuprum/collections/resource'
require 'cuprum/collections/rspec/fixtures'

require 'support/examples/commands'

module Spec::Support::Examples::Commands
  module ResourcesExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_context 'with parameters for a resource command' do
      let(:repository) { Cuprum::Collections::Basic::Repository.new }
      let(:resource) do
        Cuprum::Rails::Resource.new(name: 'books', **resource_options)
      end
      let(:resource_options) { {} }
    end

    deferred_examples 'should implement the resource command methods' do
      describe '.new' do
        define_method :tools do
          SleepingKingStudios::Tools::Toolbelt.instance
        end

        describe 'with repository: nil' do
          let(:repository) { nil }
          let(:error_message) do
            tools.assertions.error_message_for(
              'sleeping_king_studios.tools.assertions.instance_of',
              as:       'repository',
              expected: Cuprum::Collections::Repository
            )
          end

          it 'should raise an exception' do
            expect { described_class.new(repository:, resource:) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with repository: an Object' do
          let(:repository) { Object.new.freeze }
          let(:error_message) do
            tools.assertions.error_message_for(
              'sleeping_king_studios.tools.assertions.instance_of',
              as:       'repository',
              expected: Cuprum::Collections::Repository
            )
          end

          it 'should raise an exception' do
            expect { described_class.new(repository:, resource:) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with resource: nil' do
          let(:resource) { nil }
          let(:error_message) do
            tools.assertions.error_message_for(
              'sleeping_king_studios.tools.assertions.instance_of',
              as:       'resource',
              expected: Cuprum::Collections::Resource
            )
          end

          it 'should raise an exception' do
            expect { described_class.new(repository:, resource:) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with resource: an Object' do
          let(:resource) { Object.new.freeze }
          let(:error_message) do
            tools.assertions.error_message_for(
              'sleeping_king_studios.tools.assertions.instance_of',
              as:       'resource',
              expected: Cuprum::Collections::Resource
            )
          end

          it 'should raise an exception' do
            expect { described_class.new(repository:, resource:) }
              .to raise_error ArgumentError, error_message
          end
        end
      end

      describe '#collection' do
        let(:expected) do
          repository.find_or_create(qualified_name: resource.qualified_name)
        end

        include_examples 'should define private reader',
          :collection,
          -> { expected }

        context 'when the resource has a scope' do
          let(:resource_scope) do
            ->(query) { { 'series' => query.not_equal(nil) } }
          end
          let(:resource_options) do
            super().merge(scope: resource_scope)
          end
          let(:expected_scope) { expected.scope.and(&resource_scope) }

          it 'should apply the resource scope to the collection' do
            collection = subject.send(:collection)

            expect(collection.scope).to be == expected_scope
          end
        end
      end

      describe '#tools' do
        let(:toolbelt) do
          SleepingKingStudios::Tools::Toolbelt.instance
        end

        include_examples 'should define private reader', :tools

        it { expect(subject.send(:tools)).to be toolbelt }
      end
    end
  end
end
