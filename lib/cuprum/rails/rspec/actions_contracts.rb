# frozen_string_literal: true

require 'cuprum/collections/errors/not_found'
require 'cuprum/collections/repository'
require 'rspec/sleeping_king_studios/contract'

require 'cuprum/rails/map_errors'
require 'cuprum/rails/rspec'
require 'cuprum/rails/rspec/contract_helpers'

module Cuprum::Rails::RSpec
  # Namespace for RSpec action contracts, which validate action implementations.
  module ActionsContracts
    # Contract validating the interface for an action.
    module ActionContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        describe '.new' do
          it 'should define the constructor' do
            expect(described_class)
              .to respond_to(:new)
              .with(0).arguments
              .and_keywords(:repository, :resource)
              .and_any_keywords
          end
        end

        describe '#call' do
          it 'should define the method' do
            expect(action)
              .to be_callable
              .with(0).arguments
              .and_keywords(:request)
          end
        end

        describe '#repository' do
          include_examples 'should define reader',
            :repository,
            -> { be_a Cuprum::Collections::Repository }
        end

        describe '#resource' do
          include_examples 'should define reader',
            :resource,
            -> { be_a Cuprum::Rails::Resource }
        end
      end
    end

    # Contract validating the interface for a resourceful action.
    module ResourceActionContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, require_permitted_attributes: false)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      #   @param require_permitted_attributes [Boolean] if true, should require
      #     the resource to define permitted attributes as a non-empty Array.

      contract do |require_permitted_attributes: false|
        include Cuprum::Rails::RSpec::ActionsContracts

        include_contract ActionContract

        describe '.new' do
          describe 'with a resource without a collection' do
            let(:resource) do
              Cuprum::Rails::Resource.new(resource_name: 'books')
            end
            let(:error_message) do
              'resource must have a collection'
            end

            it 'should raise an exception' do
              expect { described_class.new(resource: resource) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with a resource with permitted_attributes: nil' do
            let(:resource) do
              resource = super()

              Cuprum::Rails::Resource.new(
                collection:           resource.collection,
                permitted_attributes: nil,
                resource_name:        resource.resource_name
              )
            end
            let(:error_message) do
              'resource must define permitted attributes'
            end

            if require_permitted_attributes
              it 'should raise an exception' do
                expect { described_class.new(resource: resource) }
                  .to raise_error ArgumentError, error_message
              end
            else
              it 'should not raise an exception' do
                expect { described_class.new(resource: resource) }
                  .not_to raise_error
              end
            end
          end

          describe 'with a resource with permitted_attributes: an empty Array' \
          do
            let(:resource) do
              resource = super()

              Cuprum::Rails::Resource.new(
                collection:           resource.collection,
                permitted_attributes: [],
                resource_name:        resource.resource_name
              )
            end
            let(:error_message) do
              'resource must define permitted attributes'
            end

            if require_permitted_attributes
              it 'should raise an exception' do
                expect { described_class.new(resource: resource) }
                  .to raise_error ArgumentError, error_message
              end
            else
              it 'should not raise an exception' do
                expect { described_class.new(resource: resource) }
                  .not_to raise_error
              end
            end
          end
        end

        describe '#collection' do
          include_examples 'should define reader',
            :collection,
            -> { action.resource.collection }
        end

        describe '#resource_class' do
          include_examples 'should define reader',
            :resource_class,
            -> { resource.resource_class }
        end

        describe '#resource_id' do
          let(:params) { {} }
          let(:request) do
            Cuprum::Rails::Request.new(params: params)
          end
          let(:action) do
            super().tap { |action| action.call(request: request) }
          end

          it { expect(action).to respond_to(:resource_id).with(0).arguments }

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

        describe '#resource_name' do
          include_examples 'should define reader',
            :resource_name,
            -> { action.resource.resource_name }
        end

        describe '#resource_params' do
          let(:params) { {} }
          let(:request) do
            Cuprum::Rails::Request.new(params: params)
          end
          let(:action) do
            super().tap { |action| action.call(request: request) }
          end

          it 'should define the method' do
            expect(action).to respond_to(:resource_params).with(0).arguments
          end

          context 'when the parameters do not include params for the resource' \
          do
            let(:params) { {} }

            it { expect(action.resource_params).to be == {} }
          end

          context 'when the params for the resource are empty' do
            let(:params) { { resource.singular_resource_name => {} } }

            it { expect(action.resource_params).to be == {} }
          end

          context 'when the parameter for the resource is not a Hash' do
            let(:params) { { resource.singular_resource_name => 'invalid' } }

            it { expect(action.resource_params).to be == 'invalid' }
          end

          context 'when the parameters include the params for resource' do
            let(:params) do
              resource_params =
                action
                  .resource
                  .permitted_attributes
                  .then { |ary| ary || [] }
                  .to_h { |attr_name| [attr_name.to_s, "#{attr_name} value"] }

              { action.resource.singular_resource_name => resource_params }
            end
            let(:expected) { params[action.resource.singular_resource_name] }

            it { expect(action.resource_params).to be == expected }
          end
        end

        describe '#singular_resource_name' do
          include_examples 'should define reader',
            :singular_resource_name,
            -> { action.resource.singular_resource_name }
        end

        describe '#transaction' do
          let(:transaction_class) { resource.resource_class }

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
                configured_existing_entity[action.resource.primary_key]

              option_with_default(
                options[:params],
                default: { 'id' => resource_id }
              )
            end
            let(:configured_expected_value) do
              resource_name = action.resource.singular_resource_name

              option_with_default(
                options[:expected_value],
                default: { resource_name => configured_existing_entity }
              )
            end

            it 'should return a passing result' do
              expect(action.call(request: request))
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
                attribute_name:  action.resource.primary_key.intern,
                attribute_value: configured_primary_key_value,
                collection_name: action.resource.resource_name,
                primary_key:     true
              )
            end

            before(:example) do
              resource
                .resource_class
                .where(
                  action.resource.primary_key => configured_primary_key_value
                )
                .destroy_all
            end

            it 'should return a failing result' do
              expect(action.call(request: request))
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
                  hsh.delete(action.resource.singular_resource_name)
                end
            end
            let(:configured_expected_error) do
              errors = Stannum::Errors.new.tap do |err|
                err[action.resource.singular_resource_name]
                  .add(Stannum::Constraints::Presence::TYPE)
              end

              Cuprum::Rails::Errors::InvalidParameters.new(errors: errors)
            end

            it 'should return a failing result' do
              expect(action.call(request: request))
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
                .merge(action.resource.singular_resource_name => 'invalid')
            end
            let(:configured_expected_error) do
              errors = Stannum::Errors.new.tap do |err|
                err[action.resource.singular_resource_name].add(
                  Stannum::Constraints::Type::TYPE,
                  allow_empty: true,
                  required:    true,
                  type:        Hash
                )
              end

              Cuprum::Rails::Errors::InvalidParameters.new(errors: errors)
            end

            it 'should return a failing result' do
              expect(action.call(request: request))
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
              expect(action.call(request: request))
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
              resource_name = action.resource.singular_resource_name

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
                action
                  .resource
                  .collection
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
                  .resource_class
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
                  action.resource.singular_resource_name => matcher
                }
              )
            end
            let(:configured_expected_error) do
              errors =
                Cuprum::Rails::MapErrors
                  .instance
                  .call(native_errors: configured_expected_entity.errors)

              Cuprum::Collections::Errors::FailedValidation.new(
                entity_class: action.resource.resource_class,
                errors:       scope_validation_errors(errors)
              )
            end

            def scope_validation_errors(errors)
              mapped_errors = Stannum::Errors.new
              resource_name = action.resource.singular_resource_name

              errors.each do |err|
                mapped_errors
                  .dig(resource_name, *err[:path].map(&:to_s))
                  .add(err[:type], message: err[:message], **err[:data])
              end

              mapped_errors
            end

            it 'should return a failing result' do
              expect(action.call(request: request))
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
