# frozen_string_literal: true

require 'cuprum/collections/repository'
require 'rspec/sleeping_king_studios/contract'

require 'cuprum/rails/map_errors'
require 'cuprum/rails/rspec'
require 'cuprum/rails/rspec/contract_helpers'

module Cuprum::Rails::RSpec
  # Namespace for RSpec action contracts, which validate action implementations.
  module ActionsContracts
    # Contract validating the interface for a resourceful action.
    module ResourceActionContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] The example group to
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
        end

        describe '#call' do
          def be_callable
            respond_to(:process, true)
          end

          it 'should define the method' do
            expect(action)
              .to be_callable
              .with(0).arguments
              .and_keywords(:request)
          end
        end

        describe '#collection' do
          include_examples 'should define reader',
            :collection,
            -> { action.resource.collection }
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

        describe '#resource_id' do
          let(:params) { {} }
          let(:request) do
            instance_double(Cuprum::Rails::Request, params: params)
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
            instance_double(Cuprum::Rails::Request, params: params)
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
                  .yield_self { |ary| ary || [] }
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
      #
      #   @yield Additional configuration or examples.

      contract do |existing_entity:, **contract_options, &block|
        contract_options = contract_options.merge(
          existing_entity: existing_entity
        )

        describe '#call' do
          include Cuprum::Rails::RSpec::ContractHelpers

          let(:params) do
            defined?(super()) ? super() : {}
          end
          let(:request) do
            instance_double(Cuprum::Rails::Request, params: params)
          end

          context 'when the entity exists' do
            let(:existing_entity) do
              option_with_default(
                configured: contract_options[:existing_entity],
                context:    self
              )
            end
            let(:primary_key) { resource.primary_key }
            let(:params) do
              super().merge('id' => self.existing_entity[primary_key])
            end
            let(:expected_value) do
              option_with_default(
                configured: contract_options[:expected_value],
                context:    self,
                default:    {
                  action.resource.singular_resource_name => self.existing_entity
                }
              )
            end

            it 'should return a passing result' do
              expect(action.call(request: request))
                .to be_a_passing_result
                .with_value(expected_value)
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
      #   @option options [Object] primary_key_value The value of the primary
      #     key for the missing entity.
      #
      #   @yield Additional configuration or examples.

      contract do |**contract_options, &block|
        describe '#call' do
          include Cuprum::Rails::RSpec::ContractHelpers

          let(:params) do
            defined?(super()) ? super() : {}
          end
          let(:request) do
            instance_double(Cuprum::Rails::Request, params: params)
          end

          context 'when the entity does not exist' do
            let(:expected_error) do
              Cuprum::Collections::Errors::NotFound.new(
                collection_name:    resource.resource_name,
                primary_key_name:   resource.primary_key,
                primary_key_values: primary_key_value
              )
            end
            let(:primary_key_value) do
              option_with_default(
                configured: contract_options[:primary_key_value],
                context:    self,
                default:    0
              )
            end
            let(:params) { super().merge('id' => primary_key_value) }

            before(:example) do
              resource
                .resource_class
                .where(resource.primary_key => primary_key_value)
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
      #   @yield Additional configuration or examples.

      contract do |&block|
        describe '#call' do
          let(:params) do
            defined?(super()) ? super() : {}
          end
          let(:request) do
            instance_double(Cuprum::Rails::Request, params: params)
          end

          context 'when the parameters do not include params for the resource' \
          do
            let(:params) do
              super()
                .dup
                .tap do |hsh|
                  hsh.delete(action.resource.singular_resource_name)
                end
            end
            let(:expected_error) do
              Cuprum::Rails::Errors::MissingParameters
                .new(resource_name: action.resource.singular_resource_name)
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

    # Contract asserting the action requires permitted attributes.
    module ShouldRequirePermittedAttributesContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] The example group to
      #     which the contract is applied.
      #
      #   @yield Additional configuration or examples.

      contract do |&block|
        describe '#call' do
          let(:params) do
            defined?(super()) ? super() : {}
          end
          let(:request) do
            instance_double(Cuprum::Rails::Request, params: params)
          end

          context 'when the resource does not define permitted attributes' do
            let(:expected_error) do
              Cuprum::Rails::Errors::UndefinedPermittedAttributes
                .new(resource_name: resource.singular_resource_name)
            end

            before(:example) do
              allow(action.resource)
                .to receive(:permitted_attributes)
                .and_return(nil)
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

    # Contract asserting the action requires a primary key.
    module ShouldRequirePrimaryKeyContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] The example group to
      #     which the contract is applied.
      #
      #   @yield Additional configuration or examples.

      contract do |&block|
        describe '#call' do
          let(:params) do
            defined?(super()) ? super() : {}
          end
          let(:request) do
            instance_double(Cuprum::Rails::Request, params: params)
          end

          context 'when the parameters do not include a primary key' do
            let(:params) do
              super()
                .dup
                .tap { |hsh| hsh.delete('id') }
            end
            let(:expected_error) do
              Cuprum::Rails::Errors::MissingPrimaryKey.new(
                primary_key:   resource.primary_key,
                resource_name: resource.singular_resource_name
              )
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

    # Contract asserting the action validates the created or updated entity.
    module ShouldValidateAttributesContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, invalid_attributes:, expected_attributes: nil) # rubocop:disable Layout/LineLength
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] The example group to
      #     which the contract is applied.
      #   @param invalid_attributes [Hash<String>] A set of attributes that will
      #     fail validation.
      #   @param expected_attributes [Hash<String>] The expected attributes for
      #     the returned object. Defaults to the value of invalid_attributes.
      #
      #   @yield Additional configuration or examples.

      contract do |invalid_attributes:, **contract_options, &block|
        contract_options.update(invalid_attributes: invalid_attributes)

        describe '#call' do
          include Cuprum::Rails::RSpec::ContractHelpers

          let(:params) do
            defined?(super()) ? super() : {}
          end
          let(:request) do
            instance_double(Cuprum::Rails::Request, params: params)
          end

          context 'when the resource params fail validation' do
            let(:invalid_attributes) do
              option_with_default(
                configured: contract_options[:invalid_attributes],
                context:    self
              )
            end
            let(:expected_attributes) do
              option_with_default(
                configured: contract_options[:expected_attributes],
                context:    self,
                default:    self.invalid_attributes
              )
            end
            let(:params) do
              resource_name = action.resource.singular_resource_name

              super().merge({
                resource_name => self.invalid_attributes
              })
            end
            let(:expected_entity) do
              action
                .resource
                .resource_class
                .new(expected_attributes)
                .tap(&:valid?)
            end
            let(:expected_value) do
              matcher =
                be_a(expected_entity.class)
                  .and(have_attributes(expected_entity.attributes))
              option_with_default(
                configured: contract_options[:expected_value],
                context:    self,
                default:    {
                  action.resource.singular_resource_name => matcher
                }
              )
            end
            let(:expected_error) do
              errors =
                Cuprum::Rails::MapErrors
                  .instance
                  .call(native_errors: expected_entity.errors)

              Cuprum::Collections::Errors::FailedValidation.new(
                entity_class: action.resource.resource_class,
                errors:       errors
              )
            end

            it 'should return a failing result' do
              expect(action.call(request: request))
                .to be_a_failing_result
                .with_value(deep_match(expected_value))
                .and_error(expected_error)
            end

            instance_exec(&block) if block
          end
        end
      end
    end
  end
end
