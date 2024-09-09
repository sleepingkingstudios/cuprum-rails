# frozen_string_literal: true

require 'cuprum/rails/records/command'

require 'support/examples/records/command_examples'

RSpec.describe Cuprum::Rails::Records::Command do
  include Spec::Support::Examples::Records::CommandExamples

  subject(:command) { described_class.new(collection:) }

  include_deferred 'with parameters for a records command'

  include_deferred 'should implement the Records::Command methods'

  describe '#call' do
    it 'should define the method' do
      expect(command)
        .to respond_to(:call)
        .with_unlimited_arguments
        .and_any_keywords
    end

    it 'should return a failing result with not implemented error' do
      expect(command.call)
        .to be_a_failing_result
        .with_error(an_instance_of Cuprum::Errors::CommandNotImplemented)
    end
  end

  describe '#validate_entity' do
    let(:expected_message) do
      "entity is not an instance of #{collection.entity_class}"
    end

    it 'should define the private method' do
      expect(command)
        .to respond_to(:validate_entity, true)
        .with(1).argument
        .and_keywords(:as)
    end

    describe 'with nil' do
      it 'should return the error message' do
        expect(command.send(:validate_entity, nil))
          .to be == expected_message
      end
    end

    describe 'with an Object' do
      it 'should return the error message' do
        expect(command.send(:validate_entity, Object.new.freeze))
          .to be == expected_message
      end
    end

    describe 'with an invalid record' do
      it 'should return the error message' do
        expect(command.send(:validate_entity, Tome.new))
          .to be == expected_message
      end
    end

    describe 'with a valid record' do
      it { expect(command.send(:validate_entity, Book.new)).to be nil }
    end

    wrap_deferred 'with a collection with a custom primary key' do
      describe 'with an invalid record' do
        it 'should return the error message' do
          expect(command.send(:validate_entity, Book.new))
            .to be == expected_message
        end
      end

      describe 'with a valid record' do
        it { expect(command.send(:validate_entity, Tome.new)).to be nil }
      end
    end
  end
end
