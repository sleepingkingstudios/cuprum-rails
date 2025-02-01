# frozen_string_literal: true

require 'cuprum/rails/commands/validate_entity'

require 'support/book'

RSpec.describe Cuprum::Rails::Commands::ValidateEntity do
  subject(:command) { described_class.new(collection:) }

  let(:collection) do
    Cuprum::Rails::Records::Collection.new(entity_class: Book)
  end

  describe '#call' do
    it 'should define the method' do
      expect(command)
        .to be_callable
        .with(0).arguments
        .and_keywords(:entity)
    end

    describe 'when the validation returns a passing result' do
      let(:entity) do
        Book.new(title: 'Gideon the Ninth', author: 'Tammsyn Muir')
      end

      it 'should return a passing result with the entity' do
        expect(command.call(entity:))
          .to be_a_passing_result
          .with_value(entity)
      end
    end

    describe 'when the validation returns a failing result' do
      let(:entity) do
        Book.new(title: 'Gideon the Ninth', author: 'Tammsyn Muir')
      end
      let(:error)  { Cuprum::Error.new(message: 'Something went wrong') }
      let(:result) { Cuprum::Result.new(error:) }
      let(:mock_command) do
        instance_double(Cuprum::Command, call: result)
      end

      before(:example) do
        allow(collection).to receive(:validate_one).and_return(mock_command)
      end

      it 'should return the failing result' do
        expect(command.call(entity:))
          .to be_a_failing_result
          .with_value(nil)
          .and_error(error)
      end
    end

    describe 'when the validation returns a validation error' do
      let(:entity) do
        Book.new(title: 'Gideon the Ninth', author: nil)
      end
      let(:expected_error) do
        collection
          .validate_one
          .call(entity:)
          .error
      end

      it 'should return a failing result with the entity' do
        expect(command.call(entity:))
          .to be_a_failing_result
          .with_value(entity)
          .and_error(expected_error)
      end
    end
  end

  describe '#collection' do
    include_examples 'should define reader', :collection, -> { collection }
  end
end
