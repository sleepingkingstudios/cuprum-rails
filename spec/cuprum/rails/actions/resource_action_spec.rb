# frozen_string_literal: true

require 'cuprum/rails/actions/resource_action'
require 'cuprum/rails/rspec/actions_contracts'

require 'support/book'

RSpec.describe Cuprum::Rails::Actions::ResourceAction do
  include Cuprum::Rails::RSpec::ActionsContracts

  subject(:action) do
    described_class.new(resource: resource, repository: repository)
  end

  let(:repository) { Cuprum::Rails::Repository.new }
  let(:collection) { repository.find_or_create(record_class: Book) }
  let(:resource) do
    Cuprum::Rails::Resource.new(
      collection:     repository.find_or_create(record_class: Book),
      resource_class: Book,
      **resource_options
    )
  end
  let(:resource_options) { {} }

  include_contract 'resource action contract'

  describe '#call' do
    shared_examples 'should call the previous action steps' do |method_name|
      let(:included_steps) do
        [*action_steps.split(method_name).first, method_name]
      end
      let(:excluded_steps) do
        action_steps.split(method_name).last
      end

      it 'should call the previous action steps', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        mocked_action.call(request: request)

        included_steps.each do |step|
          expect(mocked_action).to have_received(step)
        end

        excluded_steps.each do |step|
          expect(mocked_action).not_to have_received(step)
        end
      end
    end

    shared_examples 'should call the action step' do |method_name|
      context "when the ##{method_name} step raises an exception" do
        let(:exception) { StandardError.new('Something went wrong') }
        let(:expected_message) do
          'uncaught exception in Cuprum::Rails::Actions::ResourceAction -'
        end
        let(:expected_error) do
          Cuprum::Errors::UncaughtException.new(
            exception: exception,
            message:   expected_message
          )
        end

        before(:example) do
          allow(mocked_action).to receive(method_name).and_raise(exception)
        end

        it 'should return the failing result' do
          expect(mocked_action.call(request: request))
            .to be_a_failing_result
            .with_error(expected_error)
        end

        include_examples 'should call the previous action steps', method_name
      end

      context "when the ##{method_name} step returns a failing result" do
        let(:expected_error) do
          Cuprum::Error.new(message: 'Something went wrong')
        end
        let(:result) do
          Cuprum::Result.new(error: expected_error)
        end

        before(:example) do
          allow(mocked_action).to receive(method_name).and_return(result)
        end

        it 'should return the failing result' do
          expect(mocked_action.call(request: request))
            .to be_a_failing_result
            .with_error(expected_error)
        end

        include_examples 'should call the previous action steps', method_name
      end

      context 'when the action defines custom exception handling' do
        let(:described_class) { Spec::Action }

        # rubocop:disable RSpec/DescribedClass
        example_class 'Spec::Action', Cuprum::Rails::Actions::ResourceAction \
        do |klass|
          klass.define_method(:handle_exceptions) do |&block|
            super() do
              block.call
            rescue Spec::CustomException
              error = Cuprum::Error.new(message: 'Something went wrong')

              failure(error)
            end
          end
        end
        # rubocop:enable RSpec/DescribedClass

        example_class 'Spec::CustomException', StandardError

        context "when the ##{method_name} step raises a custom exception" do
          let(:exception) { Spec::CustomException.new('Something went wrong') }
          let(:expected_error) do
            Cuprum::Error.new(message: 'Something went wrong')
          end

          before(:example) do
            allow(mocked_action).to receive(method_name).and_raise(exception)
          end

          it 'should return the failing result' do
            expect(mocked_action.call(request: request))
              .to be_a_failing_result
              .with_error(expected_error)
          end

          include_examples 'should call the previous action steps', method_name
        end

        context "when the ##{method_name} step raises a standard exception" do
          let(:exception) { StandardError.new('Something went wrong') }
          let(:expected_message) do
            'uncaught exception in Spec::Action -'
          end
          let(:expected_error) do
            Cuprum::Errors::UncaughtException.new(
              exception: exception,
              message:   expected_message
            )
          end

          before(:example) do
            allow(mocked_action).to receive(method_name).and_raise(exception)
          end

          it 'should return the failing result' do
            expect(mocked_action.call(request: request))
              .to be_a_failing_result
              .with_error(expected_error)
          end

          include_examples 'should call the previous action steps', method_name
        end
      end
    end

    let(:params)  { {} }
    let(:request) { instance_double(ActionDispatch::Request, params: params) }
    let(:action_steps) do
      %i[
        find_required_entities
        perform_action
        build_response
      ]
    end
    let(:mocked_action) do
      action.tap do |mock|
        action_steps.each do |method_name|
          allow(mock).to receive(method_name)
        end
      end
    end

    it 'should return a passing result' do
      expect(mocked_action.call(request: request))
        .to be_a_passing_result
        .with_value(nil)
    end

    it 'should call each action step', :aggregate_failures do
      mocked_action.call(request: request)

      expect(mocked_action).to have_received(:find_required_entities)
      expect(mocked_action).to have_received(:perform_action)
      expect(mocked_action).to have_received(:build_response)
    end

    include_examples 'should call the action step', :build_response

    include_examples 'should call the action step', :find_required_entities
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
