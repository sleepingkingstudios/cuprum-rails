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

    deferred_context 'when the resource defines a scope' do
      let(:collection) do
        next super() if defined?(super())

        # :nocov:
        repository.find_or_create(qualified_name: resource.qualified_name)
        # :nocov:
      end
      let(:resource_scope) do
        next super() if defined?(super())

        Cuprum::Collections::Scope.new do |query|
          { 'published_at' => query.gte('1970-01-01') }
        end
      end
      let(:resource_options) do
        super().merge(scope: resource_scope)
      end
    end

    deferred_context 'with a valid entity' do |**examples_opts, &block|
      if examples_opts.fetch(:plural, !examples_opts.fetch(:singular, false))
        context 'when initialized with a plural resource' do
          let(:resource_options) { super().merge(plural: true) }

          include_deferred('with a valid entity by primary key', &block)
        end
      end

      if examples_opts.fetch(:singular, !examples_opts.fetch(:plural, false))
        context 'when initialized with a singular resource' do
          let(:resource_options) { super().merge(plural: false) }

          include_deferred('with a valid entity by scoped uniqueness', &block)
        end
      end
    end

    deferred_context 'with a valid entity by primary key' do |&block|
      describe 'with entity: value' do
        include_deferred 'when the collection has many items'

        let(:entity) do
          defined?(super()) ? super() : collection_data.first
        end
        let(:expected_entity) do
          defined?(super()) ? super() : entity
        end
        let(:primary_key) { nil }

        block ? instance_exec(&block) : pending
      end

      wrap_deferred 'when the collection has many items' do
        describe 'with primary_key: a valid value' do
          let(:expected_entity) do
            defined?(super()) ? super() : collection_data.first
          end
          let(:valid_primary_key_value) do
            next super() if defined?(super())

            expected_entity[resource.primary_key_name]
          end
          let(:entity)      { nil }
          let(:primary_key) { valid_primary_key_value }

          block ? instance_exec(&block) : pending
        end

        wrap_deferred 'when the resource defines a scope' do
          describe 'with primary_key: a valid value' do
            let(:valid_scoped_primary_key_value) do
              next super() if defined?(super())

              collection
                .with_scope(resource_scope)
                .find_matching
                .call(limit: 1)
                .value
                .first
                .then { |item| item[resource.primary_key_name] }
            end
            let(:entity)      { nil }
            let(:primary_key) { valid_scoped_primary_key_value }
            let(:expected_entity) do
              next super() if defined?(super())

              collection_data.find do |item|
                item[resource.primary_key_name] ==
                  valid_scoped_primary_key_value
              end
            end

            block ? instance_exec(&block) : pending
          end
        end
      end
    end

    deferred_context 'with a valid entity by scoped uniqueness' do |&block|
      let(:primary_key) { nil }

      describe 'with entity: value' do
        include_deferred 'when the collection has many items'

        let(:entity) do
          defined?(super()) ? super() : collection_data[0]
        end
        let(:expected_entity) do
          defined?(super()) ? super() : entity
        end

        block ? instance_exec(&block) : pending
      end

      wrap_deferred 'when the collection has many items' do
        let(:entity) { nil }

        context 'when there is one matching item' do
          let(:fixtures_data) { super()[0..0] }
          let(:expected_entity) do
            next super() if defined?(super())

            collection_data.first
          end

          block ? instance_exec(&block) : pending
        end

        wrap_deferred 'when the resource defines a scope' do
          context 'when there is one matching item' do
            let(:unique_scope) do
              next super() if defined?(super())

              Cuprum::Collections::Scope.new do |query|
                {
                  'author'       => 'J.R.R. Tolkien',
                  'published_at' => query.gte('1970-01-01')
                }
              end
            end
            let(:resource_scope) { unique_scope }
            let(:entity)         { nil }
            let(:unique_entity) do
              collection
                .with_scope(unique_scope)
                .find_matching
                .call
                .value
                .first
            end
            let(:expected_unique_entity) do
              next super() if defined?(super())

              unique_entity
            end
            let(:expected_entity) { expected_unique_entity }

            block ? instance_exec(&block) : pending
          end
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

    deferred_examples 'should require entity' do |**examples_opts|
      if examples_opts.fetch(:plural, !examples_opts.fetch(:singular, false))
        context 'when initialized with a plural resource' do
          let(:resource_options) { super().merge(plural: true) }

          include_deferred 'should require entity by primary key'
        end
      end

      if examples_opts.fetch(:singular, !examples_opts.fetch(:plural, false))
        context 'when initialized with a singular resource' do
          let(:resource_options) { super().merge(plural: false) }

          include_deferred 'should require entity by scoped uniqueness'
        end
      end
    end

    deferred_examples 'should require entity by primary key' do
      describe 'with no entity parameters' do
        let(:entity)      { nil }
        let(:primary_key) { nil }

        # @todo: Remove this spec when parameter validation is implemented for
        #   commands.
        it 'should return a failing result' do
          expect(call_command).to be_a_failing_result
        end
      end

      describe 'with primary_key: an invalid value' do
        let(:fixtures_data) do
          next super() if defined?(super())

          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
        end
        let(:collection_data) do
          next super() if defined?(super())

          fixtures_data
        end
        let(:invalid_primary_key_value) do
          next super() if defined?(super())

          collection_data
            .map { |item| item[resource.primary_key_name] } # rubocop:disable Rails/Pluck
            .max
            .then { |value| (value || 0) + 1 }
        end
        let(:entity)      { nil }
        let(:primary_key) { invalid_primary_key_value }
        let(:expected_error) do
          Cuprum::Collections::Errors::NotFound.new(
            attribute_name:  resource.primary_key_name,
            attribute_value: invalid_primary_key_value,
            collection_name: resource.name,
            primary_key:     true
          )
        end

        it 'should return a failing result' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      wrap_deferred 'when the collection has many items' do
        describe 'with primary_key: an invalid value' do
          let(:invalid_primary_key_value) do
            next super() if defined?(super())

            collection_data
              .map { |item| item[resource.primary_key_name] } # rubocop:disable Rails/Pluck
              .max + 1
          end
          let(:entity)      { nil }
          let(:primary_key) { invalid_primary_key_value }
          let(:expected_error) do
            Cuprum::Collections::Errors::NotFound.new(
              attribute_name:  resource.primary_key_name,
              attribute_value: invalid_primary_key_value,
              collection_name: resource.name,
              primary_key:     true
            )
          end

          it 'should return a failing result' do
            expect(call_command)
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end

        wrap_deferred 'when the resource defines a scope' do
          describe 'with primary_key: an invalid value' do
            let(:invalid_scoped_primary_key_value) do
              next super() if defined?(super())

              collection
                .with_scope(resource_scope.invert)
                .find_matching
                .call(limit: 1)
                .value
                .first
                .then { |item| item[resource.primary_key_name] }
            end
            let(:entity)      { nil }
            let(:primary_key) { invalid_scoped_primary_key_value }
            let(:expected_error) do
              Cuprum::Collections::Errors::NotFound.new(
                attribute_name:  resource.primary_key_name,
                attribute_value: invalid_scoped_primary_key_value,
                collection_name: resource.name,
                primary_key:     true
              )
            end

            it 'should return a failing result' do
              expect(call_command)
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end
        end
      end
    end

    deferred_examples 'should require entity by scoped uniqueness' do
      let(:primary_key) { nil }

      context 'when there are no matching items' do
        let(:entity) { nil }
        let(:expected_error) do
          collection = repository[resource.qualified_name]

          Cuprum::Collections::Errors::NotFound.new(
            collection_name: collection.name,
            query:           collection.query
          )
        end

        it 'should return a failing result' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      wrap_deferred 'when the collection has many items' do
        let(:entity) { nil }

        context 'when there are many matching items' do
          let(:expected_error) do
            collection = repository[resource.qualified_name]

            Cuprum::Collections::Errors::NotUnique.new(
              collection_name: collection.name,
              query:           collection.query
            )
          end

          it 'should return a failing result' do
            expect(call_command)
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end

        wrap_deferred 'when the resource defines a scope' do
          context 'when there are no matching items' do
            let(:non_matching_scope) do
              next super() if defined?(super())

              Cuprum::Collections::Scope.new do |query|
                { 'published_at' => query.gte('2070-01-01') }
              end
            end
            let(:resource_scope) { non_matching_scope }
            let(:entity)         { nil }
            let(:expected_error) do
              collection =
                repository[resource.qualified_name].with_scope(resource_scope)

              Cuprum::Collections::Errors::NotFound.new(
                collection_name: collection.name,
                query:           collection.query
              )
            end

            it 'should return a failing result' do
              expect(call_command)
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end

          context 'when there are many matching items' do
            let(:entity)         { nil }
            let(:expected_error) do
              collection =
                repository[resource.qualified_name].with_scope(resource_scope)

              Cuprum::Collections::Errors::NotUnique.new(
                collection_name: collection.name,
                query:           collection.query
              )
            end

            it 'should return a failing result' do
              expect(call_command)
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end
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
