# frozen_string_literal: true

require 'cuprum/collections/errors/not_found'
require 'cuprum/collections/repository'
require 'rspec/sleeping_king_studios/contract'

require 'cuprum/rails/map_errors'
require 'cuprum/rails/rspec/contract_helpers'
require 'cuprum/rails/rspec/contracts'

module Cuprum::Rails::RSpec::Contracts
  # Namespace for RSpec action contracts, which validate action implementations.
  module ActionContracts
    # Contract validating the interface for an action.
    module ShouldBeAnActionContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      #   @param options [Hash] additional options for the contract.
      #
      #   @option options required_keywords [Array[Symbol]] additional keywords
      #     required by the #call method.
      contract do |**options|
        describe '.new' do
          it { expect(described_class).to respond_to(:new).with(0).arguments }
        end

        describe '#call' do
          let(:expected_keywords) do
            %i[repository request] + options.fetch(:required_keywords, [])
          end

          it 'should define the method' do
            expect(action)
              .to be_callable
              .with(0).arguments
              .and_keywords(*expected_keywords)
              .and_any_keywords
          end
        end

        describe '#options' do
          include_examples 'should define reader', :options
        end

        describe '#params' do
          include_examples 'should define reader', :params
        end

        describe '#repository' do
          include_examples 'should define reader', :repository
        end

        describe '#request' do
          include_examples 'should define reader', :request
        end
      end
    end

    # Contract validating the interface for a resourceful action.
    module ShouldBeAResourceActionContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, **options)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      #   @param options [Hash] additional options for the conrtact.
      #
      #   @option options collection_class [String, Class] the expected class
      #     for the resource collection.
      #   @option options require_permitted_attributes [Boolean] if true, should
      #     require the resource to define permitted attributes as a non-empty
      #     Array.
      #   @option options required_keywords [Array[Symbol]] additional keywords
      #     required by the #call method.

      contract do |**options|
        include Cuprum::Rails::RSpec::Contracts::ActionContracts

        let(:configured_params) do
          return params if defined?(params)

          {}
        end
        let(:configured_repository) do
          return repository if defined?(repository)

          Cuprum::Rails::Repository.new
        end
        let(:configured_request) do
          return request if defined?(request)

          Cuprum::Rails::Request.new(params: configured_params)
        end
        let(:configured_resource) do
          return resource if defined?(resource)

          # :nocov:
          Cuprum::Rails::Resource.new(entity_class: Book)
          # :nocov:
        end
        let(:configured_action_options) do
          return action_options if defined?(action_options)

          {
            repository: configured_repository,
            resource:   configured_resource
          }
        end

        define_method(:call_action) do
          action.call(request: configured_request, **configured_action_options)
        end

        include_contract 'should be an action',
          required_keywords: [:resource, *options.fetch(:required_keywords, [])]

        describe '#call' do
          next unless options[:require_permitted_attributes]

          describe 'with a permitted_attributes: nil' do
            let(:resource) do
              Cuprum::Rails::Resource.new(
                name:                 'books',
                permitted_attributes: nil
              )
            end
            let(:expected_error) do
              Cuprum::Rails::Errors::ResourceError.new(
                message:  "permitted attributes can't be blank",
                resource: configured_resource
              )
            end

            it 'should return a failing result' do
              expect(call_action)
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end

          describe 'with a permitted_attributes: an empty Array' do
            let(:resource) do
              Cuprum::Rails::Resource.new(
                name:                 'books',
                permitted_attributes: []
              )
            end
            let(:expected_error) do
              Cuprum::Rails::Errors::ResourceError.new(
                message:  "permitted attributes can't be blank",
                resource: configured_resource
              )
            end

            it 'should return a failing result' do
              expect(call_action)
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end
        end

        describe '#collection' do
          let(:expected_collection_class) do
            next super() if defined?(super())

            options
              .fetch(:collection_class, Cuprum::Collections::Collection)
              .then { |obj| obj.is_a?(String) ? obj.constantize : obj }
          end

          before(:example) { call_action }

          include_examples 'should define reader', :collection

          it { expect(action.collection).to be_a expected_collection_class }

          it 'should set the collection name' do
            expect(action.collection.name)
              .to be == resource.name
          end

          it 'should set the entity class' do
            expect(action.collection.entity_class)
              .to be == resource.entity_class
          end

          context 'when the repository defines a matching collection' do
            let!(:existing_collection) do
              configured_repository.find_or_create(
                qualified_name: resource.qualified_name
              )
            end

            it { expect(action.collection).to be existing_collection }
          end

          context 'when there is a partially matching collection' do
            let(:configured_repository) do
              repository = super()

              repository.find_or_create(
                entity_class:   resource.entity_class,
                name:           'other_collection',
                qualified_name: resource.qualified_name
              )

              repository
            end
            let!(:existing_collection) do
              configured_repository[resource.qualified_name]
            end

            it { expect(action.collection).to be existing_collection }
          end
        end

        describe '#resource' do
          include_examples 'should define reader', :resource

          context 'when called with a resource' do
            before(:example) { call_action }

            it { expect(action.resource).to be == configured_resource }
          end
        end

        describe '#resource_id' do
          include_examples 'should define reader', :resource_id

          context 'when called with a resource' do
            let(:params)  { {} }
            let(:request) { Cuprum::Rails::Request.new(params: params) }

            before(:example) { call_action }

            context 'when the parameters do not include a primary key' do
              let(:params) { {} }

              it { expect(action.resource_id).to be nil }
            end

            context 'when the :id parameter is set' do
              let(:primary_key_value) { 0 }
              let(:params)            { { 'id' => primary_key_value } }

              it { expect(action.resource_id).to be primary_key_value }
            end
          end
        end

        describe '#resource_params' do
          include_examples 'should define reader', :resource_params

          context 'when called with a resource' do
            let(:params)  { {} }
            let(:request) { Cuprum::Rails::Request.new(params: params) }

            before(:example) { call_action }

            context 'when the parameters do not include params for the ' \
                    'resource' \
            do
              let(:params) { {} }

              it { expect(action.resource_params).to be == {} }
            end

            context 'when the params for the resource are empty' do
              let(:params) { { resource.singular_name => {} } }

              it { expect(action.resource_params).to be == {} }
            end

            context 'when the parameter for the resource is not a Hash' do
              let(:params) { { resource.singular_name => 'invalid' } }

              it { expect(action.resource_params).to be == 'invalid' }
            end

            context 'when the parameters include the params for resource' do
              let(:params) do
                resource_params =
                  configured_resource
                    .permitted_attributes
                    .then { |ary| ary || [] }
                    .to_h { |attr_name| [attr_name.to_s, "#{attr_name} value"] }

                {
                  configured_resource.singular_name => resource_params
                }
              end
              let(:expected) do
                params[configured_resource.singular_name]
              end

              it { expect(action.resource_params).to be == expected }
            end
          end
        end

        describe '#transaction' do
          let(:transaction_class) { resource.entity_class }

          before(:example) { call_action }

          it 'should define the private method' do
            expect(action).to respond_to(:transaction, true).with(0).arguments
          end

          it 'should yield the block' do
            expect { |block| action.send(:transaction, &block) }
              .to yield_control
          end

          it 'should wrap the block in a transaction' do
            in_transaction = false

            allow(transaction_class).to receive(:transaction) do |&block|
              in_transaction = true

              block.call

              in_transaction = false
            end

            action.send(:transaction) do
              expect(in_transaction).to be true
            end
          end

          context 'when the block contains a failing step' do
            let(:expected_error) do
              Cuprum::Error.new(message: 'Something went wrong.')
            end

            before(:example) do
              action.define_singleton_method(:failing_step) do
                error = Cuprum::Error.new(message: 'Something went wrong.')

                step { failure(error) }
              end
            end

            it 'should return the failing result' do
              expect(action.send(:transaction) { action.failing_step })
                .to be_a_failing_result
                .with_error(expected_error)
            end

            it 'should roll back the transaction' do
              rollback = false

              allow(transaction_class).to receive(:transaction) do |&block|
                block.call
              rescue ActiveRecord::Rollback
                rollback = true
              end

              action.send(:transaction) { action.failing_step }

              expect(rollback).to be true
            end
          end
        end
      end
    end

    # Contract asserting the action finds and returns the requested entity.
    module ShouldFindTheEntityContract
      extend RSpec::SleepingKingStudios::Contract

      # @method apply(example_group, existing_entity:, **options, &block)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] The example group to
      #     which the contract is applied.
      #   @param existing_entity [Object] The existing entity to destroy.
      #
      #   @option options [Hash<String>] expected_value The expected value for
      #     the passing result. Defaults to a Hash with the destroyed entity.
      #   @option options [Hash<String>] params The parameters used to build the
      #     request. Defaults to the id of the entity.
      #
      #   @yield Additional configuration or examples.

      contract do |existing_entity:, **options, &block|
        describe '#call' do
          include Cuprum::Rails::RSpec::ContractHelpers

          context 'when the entity exists' do
            let(:request) do
              Cuprum::Rails::Request.new(params: configured_params)
            end
            let(:configured_existing_entity) do
              option_with_default(existing_entity)
            end
            let(:configured_params) do
              resource_id =
                configured_existing_entity[configured_resource.primary_key]

              option_with_default(
                options[:params],
                default: { 'id' => resource_id }
              )
            end
            let(:configured_expected_value) do
              resource_name = configured_resource.singular_name

              option_with_default(
                options[:expected_value],
                default: { resource_name => configured_existing_entity }
              )
            end

            it 'should return a passing result' do
              expect(call_action)
                .to be_a_passing_result
                .with_value(configured_expected_value)
            end

            instance_exec(&block) if block
          end
        end
      end
    end

    # Contract asserting the action requires a valid entity.
    module ShouldRequireExistingEntityContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, **options)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] The example group to
      #     which the contract is applied.
      #
      #   @option options [Hash<String>] params The parameters used to build the
      #     request. Defaults to the id of the entity.
      #   @option options [Object] primary_key_value The value of the primary
      #     key for the missing entity.
      #
      #   @yield Additional configuration or examples.

      contract do |**options, &block|
        describe '#call' do
          include Cuprum::Rails::RSpec::ContractHelpers

          context 'when the entity does not exist' do
            let(:request) do
              Cuprum::Rails::Request.new(params: configured_params)
            end
            let(:configured_primary_key_value) do
              option_with_default(
                options[:primary_key_value],
                default: 0
              )
            end
            let(:configured_params) do
              option_with_default(
                options[:params],
                default: {}
              )
                .merge({ 'id' => configured_primary_key_value })
            end
            let(:expected_error) do
              Cuprum::Collections::Errors::NotFound.new(
                attribute_name:  configured_resource.primary_key.to_s,
                attribute_value: configured_primary_key_value,
                collection_name: configured_resource.name,
                primary_key:     true
              )
            end

            before(:example) do
              primary_key_name = configured_resource.primary_key

              resource
                .entity_class
                .where(primary_key_name => configured_primary_key_value)
                .destroy_all
            end

            it 'should return a failing result' do
              expect(call_action)
                .to be_a_failing_result
                .with_error(expected_error)
            end

            instance_exec(&block) if block
          end
        end
      end
    end

    # Contract asserting the action requires resource parameters.
    module ShouldRequireParametersContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] The example group to
      #     which the contract is applied.
      #
      #   @option options [Hash<String>] params The parameters used to build the
      #     request. Defaults to an empty Hash.
      #
      #   @yield Additional configuration or examples.

      contract do |**options, &block|
        describe '#call' do
          include Cuprum::Rails::RSpec::ContractHelpers

          context 'when the parameters do not include params for the resource' \
          do
            let(:request) do
              Cuprum::Rails::Request.new(params: configured_params)
            end
            let(:configured_params) do
              option_with_default(options[:params], default: {})
                .dup
                .tap do |hsh|
                  hsh.delete(configured_resource.singular_name)
                end
            end
            let(:configured_expected_error) do
              errors = Stannum::Errors.new.tap do |err|
                err[configured_resource.singular_name]
                  .add(Stannum::Constraints::Presence::TYPE)
              end

              Cuprum::Rails::Errors::InvalidParameters.new(errors: errors)
            end

            it 'should return a failing result' do
              expect(call_action)
                .to be_a_failing_result
                .with_error(configured_expected_error)
            end

            instance_exec(&block) if block
          end

          context 'when the resource parameters are not a Hash' do
            let(:request) do
              Cuprum::Rails::Request.new(params: configured_params)
            end
            let(:configured_params) do
              option_with_default(options[:params], default: {})
                .merge(configured_resource.singular_name => 'invalid')
            end
            let(:configured_expected_error) do
              errors = Stannum::Errors.new.tap do |err|
                err[configured_resource.singular_name].add(
                  Stannum::Constraints::Type::TYPE,
                  allow_empty: true,
                  required:    true,
                  type:        Hash
                )
              end

              Cuprum::Rails::Errors::InvalidParameters.new(errors: errors)
            end

            it 'should return a failing result' do
              expect(call_action)
                .to be_a_failing_result
                .with_error(configured_expected_error)
            end

            instance_exec(&block) if block
          end
        end
      end
    end

    # Contract asserting the action requires a primary key.
    module ShouldRequirePrimaryKeyContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, **options, &block)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] The example group to
      #     which the contract is applied.
      #
      #   @option options [Hash<String>] params The parameters used to build the
      #     request. Defaults to an empty Hash.
      #
      #   @yield Additional configuration or examples.

      contract do |**options, &block|
        describe '#call' do
          include Cuprum::Rails::RSpec::ContractHelpers

          context 'when the parameters do not include a primary key' do
            let(:request) do
              Cuprum::Rails::Request.new(params: configured_params)
            end
            let(:configured_params) do
              option_with_default(options[:params], default: {})
                .dup
                .tap { |hsh| hsh.delete('id') }
            end
            let(:configured_expected_error) do
              errors = Stannum::Errors.new.tap do |err|
                err['id'].add(Stannum::Constraints::Presence::TYPE)
              end

              Cuprum::Rails::Errors::InvalidParameters.new(errors: errors)
            end

            it 'should return a failing result' do
              expect(call_action)
                .to be_a_failing_result
                .with_error(configured_expected_error)
            end

            instance_exec(&block) if block
          end
        end
      end
    end

    # Contract asserting the action validates the created or updated entity.
    module ShouldValidateAttributesContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, invalid_attributes:, expected_attributes: nil, **options)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] The example group to
      #     which the contract is applied.
      #   @param invalid_attributes [Hash<String>] A set of attributes that will
      #     fail validation.
      #
      #   @option options [Object] existing_entity The existing entity, if any.
      #   @option options [Hash<String>] expected_attributes The expected
      #     attributes for the returned object. Defaults to the value of
      #     invalid_attributes.
      #   @option options [Hash<String>] params The parameters used to build the
      #     request. Defaults to the given attributes.
      #
      #   @yield Additional configuration or examples.

      contract do |invalid_attributes:, **options, &block|
        describe '#call' do
          include Cuprum::Rails::RSpec::ContractHelpers

          context 'when the resource params fail validation' do
            let(:request) do
              Cuprum::Rails::Request.new(params: configured_params)
            end
            let(:configured_invalid_attributes) do
              option_with_default(invalid_attributes)
            end
            let(:configured_params) do
              resource_name = configured_resource.singular_name

              option_with_default(
                options[:params],
                default: {}
              ).merge({ resource_name => configured_invalid_attributes })
            end
            let(:configured_existing_entity) do
              option_with_default(options[:existing_entity])
            end
            let(:configured_expected_attributes) do
              option_with_default(
                options[:expected_attributes],
                default: (configured_existing_entity&.attributes || {}).merge(
                  configured_invalid_attributes
                )
              )
            end
            let(:configured_expected_entity) do
              if configured_existing_entity
                repository
                  .find_or_create(
                    qualified_name: resource.qualified_name
                  )
                  .assign_one
                  .call(
                    attributes: configured_invalid_attributes,
                    entity:     configured_existing_entity.clone
                  )
                  .value
                  .tap(&:valid?)
              else
                action
                  .resource
                  .entity_class
                  .new(configured_expected_attributes)
                  .tap(&:valid?)
              end
            end
            let(:configured_expected_value) do
              matcher =
                be_a(configured_expected_entity.class)
                  .and(have_attributes(configured_expected_entity.attributes))
              option_with_default(
                options[:expected_value],
                default: {
                  configured_resource.singular_name => matcher
                }
              )
            end
            let(:configured_expected_error) do
              errors =
                Cuprum::Rails::MapErrors
                  .instance
                  .call(native_errors: configured_expected_entity.errors)

              Cuprum::Collections::Errors::FailedValidation.new(
                entity_class: configured_resource.entity_class,
                errors:       scope_validation_errors(errors)
              )
            end

            def scope_validation_errors(errors)
              mapped_errors = Stannum::Errors.new
              resource_name = configured_resource.singular_name

              errors.each do |err|
                mapped_errors
                  .dig(resource_name, *err[:path].map(&:to_s))
                  .add(err[:type], message: err[:message], **err[:data])
              end

              mapped_errors
            end

            it 'should return a failing result' do
              expect(call_action)
                .to be_a_failing_result
                .with_value(deep_match(configured_expected_value))
                .and_error(configured_expected_error)
            end

            instance_exec(&block) if block
          end
        end
      end
    end
  end
end
