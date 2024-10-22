# frozen_string_literal: true

require 'cuprum/collections/rspec/fixtures'
require 'rspec/sleeping_king_studios/deferred'

require 'cuprum/rails/rspec/deferred/commands'

module Cuprum::Rails::RSpec::Deferred::Commands
  # Deferred examples for validating resource command implementations.
  module ResourcesExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_context 'when the collection has many items' do
      let(:collection) do
        repository.find_or_create(qualified_name: resource.qualified_name)
      end
      let(:fixtures_data) do
        next super() if defined?(super())

        Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
      end
      let(:collection_data) do
        fixtures_data
      end

      before(:example) do
        collection_data.each do |entity|
          result = collection.insert_one.call(entity:)

          # :nocov:
          next if result.success?

          raise result.error.message
          # :nocov:
        end
      end
    end

    deferred_examples 'should require default contract' do
      context 'with a resource with default_contract: nil' do
        let(:default_contract) { nil }
        let(:entity_class) do
          repository
            .find_or_create(qualified_name: resource.qualified_name)
            .entity_class
        end
        let(:expected_error) do
          Cuprum::Collections::Errors::MissingDefaultContract.new(entity_class:)
        end

        it 'should return a failing result' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end
    end

    deferred_examples 'should require permitted attributes' do
      context 'when a resource with permitted_attributes: nil' do
        let(:resource_options) { super().merge(permitted_attributes: nil) }
        let(:expected_error) do
          Cuprum::Rails::Errors::ResourceError.new(
            message:  "permitted attributes can't be blank",
            resource:
          )
        end

        it 'should return a failing result' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      context 'when a resource with permitted_attributes: an empty Array' do
        let(:resource_options) { super().merge(permitted_attributes: []) }
        let(:expected_error) do
          Cuprum::Rails::Errors::ResourceError.new(
            message:  "permitted attributes can't be blank",
            resource:
          )
        end

        it 'should return a failing result' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end
    end

    deferred_examples 'should validate the entity' do
      let(:entity_class) do
        repository
          .find_or_create(qualified_name: resource.qualified_name)
          .entity_class
      end
      let(:entity_attributes) do
        next super() if defined?(super())

        value = call_command.value

        value.is_a?(Hash) ? value : value&.attributes
      end
      let(:expected_error) do
        collection = repository[resource.qualified_name]
        entity     =
          collection
            .build_one
            .call(attributes: entity_attributes || {})
            .value || {}
        result     = collection.validate_one.call(entity:)

        Cuprum::Collections::Errors::FailedValidation.new(
          entity_class:,
          errors:       result.error.errors
        )
      end

      it 'should return a failing result' do
        expect(call_command)
          .to be_a_failing_result
          .with_value(an_instance_of(entity_class))
          .and_error(expected_error)
      end

      it { expect(entity_attributes).to be == expected_attributes }
    end
  end
end
