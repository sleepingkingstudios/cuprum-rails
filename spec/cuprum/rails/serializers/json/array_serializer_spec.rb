# frozen_string_literal: true

require 'cuprum/rails/serializers/json/array_serializer'

RSpec.describe Cuprum::Rails::Serializers::Json::ArraySerializer do
  subject(:serializer) { described_class.new }

  describe '.instance' do
    let(:instance) { described_class.instance }

    it { expect(described_class).to respond_to(:instance).with(0).arguments }

    it { expect(described_class.instance).to be_a described_class }

    it { expect(described_class.instance).to be instance }
  end

  describe '#initialize' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '#call' do
    let(:object)      { nil }
    let(:serializers) { {} }
    let(:context) do
      Cuprum::Rails::Serializers::Context.new(serializers:)
    end

    it 'should define the method' do
      expect(serializer)
        .to respond_to(:call)
        .with(1).argument
        .and_keywords(:context)
    end

    describe 'with nil' do
      let(:object)        { nil }
      let(:error_message) { 'object must be an Array' }

      it 'should raise an exception' do
        expect { serializer.call(object, context:) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an object' do
      let(:object)        { Object.new.freeze }
      let(:error_message) { 'object must be an Array' }

      it 'should raise an exception' do
        expect { serializer.call(object, context:) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an empty array' do
      let(:object)   { [] }
      let(:expected) { [] }

      it 'should serialize the array' do
        expect(serializer.call(object, context:))
          .to be == expected
      end
    end

    describe 'with an array with many items' do
      let(:object) { [4, 'lights'] }

      context 'when there are not matching serializers for any of the items' do
        let(:error_message) { 'no serializer defined for Integer' }

        it 'should raise an exception' do
          expect { serializer.call(object, context:) }
            .to raise_error(
              Cuprum::Rails::Serializers::Context::UndefinedSerializerError,
              error_message
            )
        end
      end

      context 'when there are not matching serializers for all of the items' do
        let(:serializers) do
          {
            Integer => instance_double(described_class, call: 'int')
          }
        end
        let(:error_message) { 'no serializer defined for String' }

        it 'should raise an exception' do
          expect { serializer.call(object, context:) }
            .to raise_error(
              Cuprum::Rails::Serializers::Context::UndefinedSerializerError,
              error_message
            )
        end
      end

      context 'when there are matching serializers for all of the items' do
        let(:serializers) do
          {
            Integer => instance_double(described_class, call: 'int'),
            String  => instance_double(described_class, call: 'str')
          }
        end
        let(:expected) { %w[int str] }

        it 'should serialize the array' do
          expect(serializer.call(object, context:))
            .to be == expected
        end
      end
    end

    describe 'with an array of arrays' do
      let(:object) do
        [
          [4, 'calling birds'],
          [3, 'french hens'],
          [2, 'turtle doves']
        ]
      end
      let(:serializers) do
        {
          Array   => described_class.instance,
          Integer => instance_double(described_class, call: 'int'),
          String  => instance_double(described_class, call: 'str')
        }
      end
      let(:expected) do
        [%w[int str], %w[int str], %w[int str]]
      end

      it 'should serialize the array' do
        expect(serializer.call(object, context:))
          .to be == expected
      end
    end
  end
end
