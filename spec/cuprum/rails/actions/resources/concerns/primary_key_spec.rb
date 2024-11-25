# frozen_string_literal: true

require 'cuprum/rails/actions/resources/concerns/primary_key'

RSpec.describe Cuprum::Rails::Actions::Resources::Concerns::PrimaryKey do
  subject(:action) { described_class.new(command_class:) }

  let(:described_class) { Spec::ExampleAction }
  let(:command_class)   { Cuprum::Rails::Command.subclass(&:itself) }

  example_class 'Spec::ExampleAction', Cuprum::Rails::Action do |klass|
    klass.include Cuprum::Rails::Actions::Resources::Concerns::PrimaryKey # rubocop:disable RSpec/DescribedClass

    klass.define_method(:map_parameters) do
      { primary_key_value: }
    end
  end

  describe '#call' do
    let(:params)            { { secret: '12345' } }
    let(:repository)        { Cuprum::Collections::Basic::Repository.new }
    let(:resource)          { Cuprum::Rails::Resource.new(name: 'books') }
    let(:request)           { instance_double(Cuprum::Rails::Request, params:) }
    let(:primary_key_value) { nil }
    let(:expected_value) do
      { primary_key_value: }
    end

    def call_action
      action.call(repository:, request:, resource:)
    end

    it 'should return a passing result' do
      expect(call_action)
        .to be_a_passing_result
        .with_value(expected_value)
    end

    describe 'with book_id: nil' do
      let(:params) { super().merge('book_id' => nil) }

      it 'should return a passing result' do
        expect(call_action)
          .to be_a_passing_result
          .with_value(expected_value)
      end
    end

    describe 'with book_id: value' do
      let(:primary_key_value) { 0 }
      let(:params)            { super().merge('book_id' => primary_key_value) }

      it 'should return a passing result' do
        expect(call_action)
          .to be_a_passing_result
          .with_value(expected_value)
      end
    end

    describe 'with id: nil' do
      let(:params) { super().merge('id' => nil) }

      it 'should return a passing result' do
        expect(call_action)
          .to be_a_passing_result
          .with_value(expected_value)
      end
    end

    describe 'with id: value' do
      let(:primary_key_value) { 0 }
      let(:params)            { super().merge('id' => primary_key_value) }

      it 'should return a passing result' do
        expect(call_action)
          .to be_a_passing_result
          .with_value(expected_value)
      end
    end

    context 'when the command requires a primary key value' do
      let(:expected_error) do
        errors = Stannum::Errors.new
        errors['id'].add(Stannum::Constraints::Presence::TYPE)

        Cuprum::Rails::Errors::InvalidParameters.new(errors:)
      end

      before(:example) do
        described_class.define_method(:map_parameters) do
          primary_key = step { require_primary_key_value }

          { primary_key_value: primary_key }
        end
      end

      it 'should return a failing result' do
        expect(call_action)
          .to be_a_failing_result
          .with_error(expected_error)
      end

      describe 'with book_id: nil' do
        let(:params) { super().merge('book_id' => nil) }

        it 'should return a failing result' do
          expect(call_action)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with book_id: value' do
        let(:primary_key_value) { 0 }
        let(:params) do
          super().merge('book_id' => primary_key_value)
        end

        it 'should return a passing result' do
          expect(call_action)
            .to be_a_passing_result
            .with_value(expected_value)
        end
      end

      describe 'with id: nil' do
        let(:params) { super().merge('id' => nil) }

        it 'should return a failing result' do
          expect(call_action)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with id: value' do
        let(:primary_key_value) { 0 }
        let(:params)            { super().merge('id' => primary_key_value) }

        it 'should return a passing result' do
          expect(call_action)
            .to be_a_passing_result
            .with_value(expected_value)
        end
      end
    end
  end
end
