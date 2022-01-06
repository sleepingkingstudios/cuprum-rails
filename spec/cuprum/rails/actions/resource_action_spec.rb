# frozen_string_literal: true

require 'cuprum/rails/actions/resource_action'

require 'support/book'
require 'support/examples/action_examples'

RSpec.describe Cuprum::Rails::Actions::ResourceAction do
  include Spec::Support::Examples::ActionExamples

  subject(:action) { described_class.new(resource: resource) }

  let(:collection) { Cuprum::Rails::Collection.new(record_class: Book) }
  let(:resource) do
    Cuprum::Rails::Resource.new(
      collection:     collection,
      resource_class: Book,
      **resource_options
    )
  end
  let(:resource_options) { {} }

  include_examples 'should define the ResourceAction methods'

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
        validate_parameters
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

      expect(mocked_action).to have_received(:validate_parameters)
      expect(mocked_action).to have_received(:find_required_entities)
      expect(mocked_action).to have_received(:perform_action)
      expect(mocked_action).to have_received(:build_response)
    end

    include_examples 'should call the action step', :build_response

    include_examples 'should call the action step', :find_required_entities

    include_examples 'should call the action step', :perform_action

    include_examples 'should call the action step', :validate_parameters
  end
end
