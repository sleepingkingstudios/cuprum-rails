# frozen_string_literal: true

require 'cuprum/collections/rspec/fixtures'
require 'rspec/sleeping_king_studios/deferred'

require 'cuprum/rails/rspec/deferred/commands'

module Cuprum::Rails::RSpec::Deferred::Commands
  # Deferred examples for validating resource command implementations.
  module ResourcesExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    # Utility context for pre-defining the collection.
    deferred_context 'when the collection is defined' do
      let!(:collection) do # rubocop:disable RSpec/LetSetup
        default_contract =
          defined?(self.default_contract) ? self.default_contract : nil

        repository.find_or_create(
          default_contract:,
          qualified_name:   resource.qualified_name,
          **collection_options
        )
      end
      let(:collection_options) do
        next super() if defined?(super())

        {}
      end
    end

    # Populates the collection with the fixtures data.
    #
    # Before each example, iterates over the fixtures data and inserts the
    # fixture into the collection. If the insert fails, an exception is raised.
    #
    # The following methods must be defined in the example group:
    #
    # - #fixtures_data: Must return an Array containing the entity attributes
    #   for the fixtures.
    #
    # The behavior can be customized by defining the following methods:
    #
    # - #collection_data: The processed fixture data, prior to inserting it into
    #   the collection. Defaults to the value of #fixtures_data.
    deferred_context 'when the collection has many items' do
      include Cuprum::Rails::RSpec::Deferred::Commands::ResourcesExamples
      include RSpec::SleepingKingStudios::Deferred::Dependencies

      depends_on :fixtures_data,
        'an Array containing the entity attributes for the fixture entities'

      include_deferred 'when the collection is defined'

      let(:collection_data) do
        next super() if defined?(super())

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

    # Defines a scope for the collection.
    #
    # The following methods must be defined in the example group:
    #
    # - #resource_scope: Must return a Cuprum::Collections::Scope that matches a
    #   subset of the fixtures.
    deferred_context 'when the resource defines a scope' do
      include RSpec::SleepingKingStudios::Deferred::Dependencies

      depends_on :resource_scope,
        'a Cuprum::Collections::Scope that matches a subset of the fixtures'

      let(:resource_options) { super().merge(scope: resource_scope) }
    end

    # Iterates over cases for commands acting on an existing entity.
    #
    # Delegates to 'with a valid entity by primary key' if the command supports
    # plural resources, and to 'with a valid entity by scoped uniqueness' if
    # the command supports singular resources.
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

    # Iterates over cases for an existing entity by value or primary key.
    #
    # This example group handles the following cases:
    #
    # - when the command is passed an entity
    # - when the command is passed a valid primary key
    # - when the command is passed a valid primary key for a given scope
    #
    # To access the actual entity for each case, call #matched_entity.
    #
    # The behavior can be customized by defining the following methods:
    #
    # - #expected_value: The value returned by the command. Defaults to the
    #   matched entity.
    # - #entity: The entity directly passed to the command. Defaults to the
    #   first item in the fixtures.
    # - #valid_primary_key_value: The value for the primary key for an unscoped
    #   collection. Defaults to the primary key value for the first item in the
    #   fixtures.
    # - #valid_scoped_primary_key_value: The value for the primary key for a
    #   scoped collection. Defaults to the primary key value for the first item
    #   in the collection that matches #resource_scope.
    deferred_context 'with a valid entity by primary key' do |&block|
      let(:matched_entity) { nil }

      describe 'with entity: value' do
        let(:entity) do
          defined?(super()) ? super() : collection_data.first
        end
        let(:primary_key)    { nil }
        let(:matched_entity) { entity }

        include_deferred 'when the collection has many items'

        block ? instance_exec(&block) : pending
      end

      wrap_deferred 'when the collection has many items' do
        describe 'with primary_key: a valid value' do
          let(:valid_primary_key_value) do
            next super() if defined?(super())

            collection_data.first[resource.primary_key_name]
          end
          let(:matched_entity) do
            collection
              .find_one
              .call(primary_key: valid_primary_key_value)
              .value
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
            let(:matched_entity) do
              collection
                .find_one
                .call(primary_key: valid_scoped_primary_key_value)
                .value
            end
            let(:entity)      { nil }
            let(:primary_key) { valid_scoped_primary_key_value }

            block ? instance_exec(&block) : pending
          end
        end
      end
    end

    # Iterates over cases for an existing entity by value or unique scope.
    #
    # This example group handles the following cases:
    #
    # - when the command is passed an entity.
    # - when the collection has one item.
    # - when the scoped collection has one item.
    #
    # To access the actual entity for each case, call #matched_entity.
    #
    # The following methods must be defined in the example group:
    #
    # - #unique_scope: Must return a Cuprum::Collections::Scope that matches
    #   exactly one of the fixtures.
    #
    # The behavior can be customized by defining the following methods:
    #
    # - #expected_value: The value returned by the command. Defaults to the
    #   matched entity.
    # - #entity: The entity directly passed to the command. Defaults to the
    #   first item in the fixtures.
    deferred_context 'with a valid entity by scoped uniqueness' do |&block|
      include RSpec::SleepingKingStudios::Deferred::Dependencies

      depends_on :unique_scope,
        'a Cuprum::Collections::Scope that exactly one of fixtures'

      let(:primary_key)    { nil }
      let(:matched_entity) { nil }

      describe 'with entity: value' do
        let(:entity) do
          defined?(super()) ? super() : collection_data.first
        end
        let(:matched_entity) { entity }

        include_deferred 'when the collection has many items'

        block ? instance_exec(&block) : pending
      end

      wrap_deferred 'when the collection has many items' do
        let(:entity) { nil }

        context 'when there is one matching item' do
          let(:fixtures_data)  { super()[0..0] }
          let(:matched_entity) { collection_data.first }

          block ? instance_exec(&block) : pending
        end

        wrap_deferred 'when the resource defines a scope' do
          context 'when there is one matching item' do
            let(:resource_scope) { unique_scope }
            let(:entity)         { nil }
            let(:matched_entity) do
              collection
                .with_scope(unique_scope)
                .find_matching
                .call
                .value
                .first
            end

            block ? instance_exec(&block) : pending
          end
        end
      end
    end

    # Examples that assert that the collection requires a default contract.
    #
    # The following methods must be defined in the example group:
    #
    # - #call_command: A method that calls the command being tested with all
    #   required parameters.
    deferred_examples 'should require default contract' do
      context 'with a resource with default_contract: nil' do
        let(:default_contract)   { nil }
        let(:matched_attributes) { {} }
        let(:entity_class)       { collection.entity_class }
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

    # Examples that assert that the command requires an entity.
    #
    # Delegates to 'should require entity by primary key' if the command
    # supports plural resources, and to 'should require entity by scoped
    # uniqueness' if the command supports singular resources.
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

    # Examples that assert the command requires an entity by primary key.
    #
    # This example group handles the following cases:
    #
    # - when the command is not passed an entity or primary key parameter.
    # - when the collection has no items.
    # - when the given primary key parameter is not a valid primary key for an
    #   item in the collection.
    # - when the given primary key parameter is not a valid primary key for an
    #   item in the collection matching the collection scope.
    #
    # The following methods must be defined in the example group:
    #
    # - #call_command: A method that calls the command being tested with all
    #   required parameters.
    deferred_examples 'should require entity by primary key' do
      include RSpec::SleepingKingStudios::Deferred::Dependencies

      depends_on :call_command,
        'method that calls the command being tested with required parameters'

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
        let(:collection_data) do
          next super() if defined?(super())

          fixtures_data
        end
        let(:invalid_primary_key_value) do
          next super() if defined?(super())

          collection_data
            .map { |item| item[resource.primary_key_name] }
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
              .map { |item| item[resource.primary_key_name] }
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

    # Examples that assert the command requires a unique entity.
    #
    # This example group handles the following cases:
    #
    # - when the collection has no items.
    # - when the collection has multiple items.
    # - when the collection has no items matching the scope.
    # - when the collection has multiple items matching the scope.
    #
    # The following methods must be defined in the example group:
    #
    # - #call_command: A method that calls the command being tested with all
    #   required parameters.
    # - #non_matching_scope: A Cuprum::Collections::Scope that does not match
    #   any fixtures.
    deferred_examples 'should require entity by scoped uniqueness' do
      include RSpec::SleepingKingStudios::Deferred::Dependencies

      depends_on :call_command,
        'method that calls the command being tested with required parameters'
      depends_on :non_matching_scope,
        'a Cuprum::Collections::Scope that does not match any fixtures'

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

    # Examples that assert that the collection requires permitted attributes.
    #
    # The following methods must be defined in the example group:
    #
    # - #call_command: A method that calls the command being tested with all
    #   required parameters.
    deferred_examples 'should require permitted attributes' do
      context 'with a resource with permitted_attributes: nil' do
        let(:resource_options)   { super().merge(permitted_attributes: nil) }
        let(:matched_attributes) { {} }
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

      context 'with a resource with permitted_attributes: an empty Array' do
        let(:resource_options)   { super().merge(permitted_attributes: []) }
        let(:matched_attributes) { {} }
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

    # Examples that assert that the command validates the entity.
    #
    # The following methods must be defined in the example group:
    #
    # - #call_command: A method that calls the command being tested with all
    #   required parameters.
    deferred_examples 'should validate the entity' do
      let(:entity_class) { collection.entity_class }
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
          errors:       result.error&.errors
        )
      end

      it 'should return a failing result' do
        expect(call_command)
          .to be_a_failing_result
          .with_value(an_instance_of(entity_class))
          .and_error(expected_error)
      end

      it { expect(entity_attributes).to match(expected_attributes) }
    end
  end
end
