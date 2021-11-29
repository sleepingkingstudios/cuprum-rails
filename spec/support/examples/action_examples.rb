# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'cuprum/rails/request'

require 'support/examples'

module Spec::Support::Examples
  module ActionExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'when the action is called with a request' do
      let(:params) { defined?(super()) ? super() : {} }
      let(:request) do
        next super() if defined?(super())

        instance_double(Cuprum::Rails::Request, params: params)
      end
      let(:action) { super().tap { |action| action.call(request: request) } }
    end

    shared_examples 'should define the ResourceAction methods' do
      describe '.new' do
        it 'should define the constructor' do
          expect(described_class)
            .to respond_to(:new)
            .with(0).arguments
            .and_keywords(:repository, :resource)
            .and_any_keywords
        end

        describe 'with a resource without a collection' do
          let(:resource) { Cuprum::Rails::Resource.new(resource_name: 'books') }
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
        let(:request) { instance_double(ActionDispatch::Request) }

        def be_callable
          respond_to(:process, true)
        end

        it 'should define the method' do
          expect(action).to be_callable.with(0).arguments.and_keywords(:request)
        end
      end

      describe '#collection' do
        include_examples 'should define reader', :collection, -> { collection }
      end

      describe '#resource_id' do
        include_context 'when the action is called with a request'

        it { expect(action).to respond_to(:resource_id).with(0).arguments }

        context 'when the parameters do not include a primary key' do
          let(:expected_error) do
            Cuprum::Rails::Errors::MissingPrimaryKey.new(
              primary_key:   resource.primary_key,
              resource_name: resource.singular_resource_name
            )
          end

          it 'should return a failing result' do
            expect(action.resource_id)
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end

        context 'when the :id parameter is set' do
          let(:primary_key_value) { 0 }
          let(:params)            { { 'id' => primary_key_value } }

          it 'should return a passing result with the primary key value' do
            expect(action.resource_id)
              .to be_a_passing_result
              .with_value(primary_key_value)
          end
        end
      end

      describe '#resource_name' do
        include_examples 'should define reader',
          :resource_name,
          -> { resource.resource_name }
      end

      describe '#resource_params' do
        include_context 'when the action is called with a request'

        let(:permitted_attributes) { %i[title author] }
        let(:resource_options) do
          super().merge(permitted_attributes: permitted_attributes)
        end

        it { expect(action).to respond_to(:resource_params).with(0).arguments }

        context 'when the resource does not define permitted attributes' do
          let(:permitted_attributes) { nil }
          let(:expected_error) do
            Cuprum::Rails::Errors::UndefinedPermittedAttributes
              .new(resource_name: resource.singular_resource_name)
          end

          it 'should return a failing result' do
            expect(action.resource_params)
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end

        context 'when the parameters do not include params for the resource' do
          let(:expected_error) do
            Cuprum::Rails::Errors::MissingParameters
              .new(resource_name: resource.singular_resource_name)
          end

          it 'should return a failing result' do
            expect(action.resource_params)
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end

        context 'when the params for the resource are empty' do
          let(:params) { { resource.singular_resource_name => {} } }
          let(:expected_error) do
            Cuprum::Rails::Errors::MissingParameters
              .new(resource_name: resource.singular_resource_name)
          end

          it 'should return a failing result' do
            expect(action.resource_params)
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end

        context 'when the parameter for the resource is not a Hash' do
          let(:params) { { resource.singular_resource_name => 'invalid' } }
          let(:expected_error) do
            Cuprum::Rails::Errors::MissingParameters
              .new(resource_name: resource.singular_resource_name)
          end

          it 'should return a failing result' do
            expect(action.resource_params)
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end

        context 'when the parameters include the params for resource' do
          let(:expected) do
            {
              'title'  => 'Gideon the Ninth',
              'author' => 'Tamsyn Muir'
            }
          end
          let(:params) do
            {
              resource.singular_resource_name => expected.merge(
                'series' => 'The Locked Tomb'
              ),
              'key'                           => 'value'
            }
          end

          it 'should return a passing result with the resource params' do
            expect(action.resource_params)
              .to be_a_passing_result
              .with_value(expected)
          end
        end
      end

      describe '#singular_resource_name' do
        include_examples 'should define reader',
          :singular_resource_name,
          -> { be == resource.singular_resource_name }
      end
    end
  end
end
