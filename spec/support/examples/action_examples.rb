# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'cuprum/rails/request'

require 'support/examples'
require 'support/book'

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

      describe '#resource_class' do
        include_examples 'should define reader',
          :resource_class,
          -> { resource.resource_class }
      end

      describe '#resource_id' do
        include_context 'when the action is called with a request'

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
          -> { resource.resource_name }
      end

      describe '#resource_params' do
        include_context 'when the action is called with a request'

        let(:permitted_attributes) { %i[title author] }
        let(:resource_options) do
          super().merge(permitted_attributes: permitted_attributes)
        end

        it { expect(action).to respond_to(:resource_params).with(0).arguments }

        context 'when the parameters do not include params for the resource' do
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
          let(:expected) do
            {
              'title'  => 'Gideon the Ninth',
              'author' => 'Tamsyn Muir'
            }
          end
          let(:params) do
            {

              'key'                           => 'value',
              resource.singular_resource_name => expected.merge(
                'series' => 'The Locked Tomb'
              )
            }
          end

          it 'should filter the resource params' do
            expect(action.resource_params).to be == expected
          end
        end
      end

      describe '#singular_resource_name' do
        include_examples 'should define reader',
          :singular_resource_name,
          -> { be == resource.singular_resource_name }
      end

      describe '#transaction' do
        shared_examples 'should wrap the block in a transaction' do
          it 'should yield the block' do
            expect { |block| action.send(:transaction, &block) }
              .to yield_control
          end

          it 'should wrap the block in a transaction' do # rubocop:disable RSpec/ExampleLength
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

            it 'should roll back the transaction' do # rubocop:disable RSpec/ExampleLength
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

        it 'should define the private method' do
          expect(action).to respond_to(:transaction, true).with(0).arguments
        end

        context 'when the resource class is not an ActiveRecord model' do
          let(:transaction_class) { ActiveRecord::Base }
          let(:resource_options) do
            super().merge(resource_class: Spec::Entity)
          end

          example_class 'Spec::Entity'

          include_examples 'should wrap the block in a transaction'
        end

        context 'when the resource class is an ActiveRecord model' do
          let(:transaction_class) { Book }
          let(:resource_options) do
            super().merge(resource_class: Book)
          end

          include_examples 'should wrap the block in a transaction'
        end
      end
    end
  end
end
