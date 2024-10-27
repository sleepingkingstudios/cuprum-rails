# frozen_string_literal: true

require 'cuprum/rails/actions/resources/concerns/entity_validation'

require 'support/book'

RSpec.describe Cuprum::Rails::Actions::Resources::Concerns::EntityValidation do
  subject(:action) { described_class.new(command_class:) }

  let(:described_class) { Spec::ExampleAction }
  let(:command_class)   { Spec::ExampleCommand }

  example_class 'Spec::ExampleCommand', Cuprum::Rails::Command do |klass|
    klass.define_method(:process) do |**properties|
      build_result(**properties)
    end
  end

  example_class 'Spec::ExampleAction', Cuprum::Rails::Action do |klass|
    klass.include \
      Cuprum::Rails::Actions::Resources::Concerns::EntityValidation # rubocop:disable RSpec/DescribedClass

    klass.define_method(:build_response) do |value|
      { resource.singular_name => value }
    end
  end

  describe '#call' do
    let(:value)      { { 'title' => 'Gideon the Ninth' } }
    let(:error)      { nil }
    let(:result)     { Cuprum::Result.new(value:, error:) }
    let(:params)     { result.properties }
    let(:repository) { Cuprum::Collections::Basic::Repository.new }
    let(:resource)   { Cuprum::Rails::Resource.new(name: 'books') }
    let(:request)    { instance_double(Cuprum::Rails::Request, params:) }
    let(:expected_value) do
      { resource.singular_name => { 'title' => 'Gideon the Ninth' } }
    end
    let(:expected_error) { error }

    def call_action
      action.call(repository:, request:, resource:)
    end

    it 'should return a passing result' do
      expect(call_action)
        .to be_a_passing_result
        .with_value(expected_value)
        .and_error(expected_error)
    end

    context 'when the command returns a failing result' do
      let(:error) do
        Cuprum::Error.new(message: 'Something went wrong')
      end
      let(:expected_value) { value }

      it 'should return a failing result' do
        expect(call_action)
          .to be_a_failing_result
          .with_value(expected_value)
          .and_error(expected_error)
      end
    end

    context 'when the command returns a result with a validation error' do
      let(:error) do
        errors = Stannum::Errors.new
        errors['author'].add(Stannum::Constraints::Presence::TYPE)

        Cuprum::Collections::Errors::FailedValidation.new(
          entity_class: resource.entity_class,
          errors:
        )
      end
      let(:expected_error) do
        errors = Stannum::Errors.new
        errors[resource.singular_name]['author']
          .add(Stannum::Constraints::Presence::TYPE)

        Cuprum::Collections::Errors::FailedValidation.new(
          entity_class: resource.entity_class,
          errors:
        )
      end

      it 'should return a failing result' do
        expect(call_action)
          .to be_a_failing_result
          .with_value(expected_value)
          .and_error(expected_error)
      end
    end
  end
end
