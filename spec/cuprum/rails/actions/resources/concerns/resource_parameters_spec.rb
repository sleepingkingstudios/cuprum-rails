# frozen_string_literal: true

require 'cuprum/rails/actions/resources/concerns/resource_parameters'

RSpec.describe Cuprum::Rails::Actions::Resources::Concerns::ResourceParameters \
do
  subject(:action) { described_class.new(command_class:) }

  let(:described_class) { Spec::ExampleAction }
  let(:command_class)   { Cuprum::Rails::Command.subclass(&:itself) }

  example_class 'Spec::ExampleAction', Cuprum::Rails::Action do |klass|
    klass.include \
      Cuprum::Rails::Actions::Resources::Concerns::ResourceParameters # rubocop:disable RSpec/DescribedClass

    klass.define_method(:map_parameters) do
      { resource_params: }
    end
  end

  describe '#call' do
    let(:params)          { { secret: '12345' } }
    let(:repository)      { Cuprum::Collections::Basic::Repository.new }
    let(:resource)        { Cuprum::Rails::Resource.new(name: 'books') }
    let(:request)         { instance_double(Cuprum::Rails::Request, params:) }
    let(:resource_params) { {} }
    let(:expected_value) do
      { resource_params: }
    end

    def call_action
      action.call(repository:, request:, resource:)
    end

    it 'should return a passing result' do
      expect(call_action)
        .to be_a_passing_result
        .with_value(expected_value)
    end

    describe 'with resource params: an empty Hash' do
      let(:params) { super().merge('book' => resource_params) }

      it 'should return a passing result' do
        expect(call_action)
          .to be_a_passing_result
          .with_value(expected_value)
      end
    end

    describe 'with resource_params: a non-empty Hash' do
      let(:resource_params) do
        {
          'title'  => 'Gideon the Ninth',
          'author' => 'Tamsyn Muir'
        }
      end
      let(:params) { super().merge('book' => resource_params) }

      it 'should return a passing result' do
        expect(call_action)
          .to be_a_passing_result
          .with_value(expected_value)
      end
    end

    context 'when the command requires resource parameters' do
      let(:expected_error) do
        errors = Stannum::Errors.new
        errors[resource.singular_name.to_s]
          .add(Stannum::Constraints::Presence::TYPE)

        Cuprum::Rails::Errors::InvalidParameters.new(errors:)
      end

      before(:example) do
        described_class.define_method(:map_parameters) do
          resource_params = step { require_resource_params }

          { resource_params: }
        end
      end

      it 'should return a failing result' do
        expect(call_action)
          .to be_a_failing_result
          .with_error(expected_error)
      end

      describe 'with resource params: an empty Hash' do
        let(:params) { super().merge('book' => resource_params) }

        it 'should return a failing result' do
          expect(call_action)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with resource_params: a non-empty Hash' do
        let(:resource_params) do
          {
            'title'  => 'Gideon the Ninth',
            'author' => 'Tamsyn Muir'
          }
        end
        let(:params) { super().merge('book' => resource_params) }

        it 'should return a passing result' do
          expect(call_action)
            .to be_a_passing_result
            .with_value(expected_value)
        end
      end
    end
  end
end
