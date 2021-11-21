# frozen_string_literal: true

require 'cuprum/rails/serializers/json/hash_serializer'

RSpec.describe Cuprum::Rails::Serializers::Json::HashSerializer do
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
      Cuprum::Rails::Serializers::Context.new(serializers: serializers)
    end

    it 'should define the method' do
      expect(serializer)
        .to respond_to(:call)
        .with(1).argument
        .and_keywords(:context)
    end

    describe 'with nil' do
      let(:object)        { nil }
      let(:error_message) { 'object must be a Hash with String keys' }

      it 'should raise an exception' do
        expect { serializer.call(object, context: context) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an object' do
      let(:object)        { Object.new.freeze }
      let(:error_message) { 'object must be a Hash with String keys' }

      it 'should raise an exception' do
        expect { serializer.call(object, context: context) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an empty hash' do
      let(:object)   { {} }
      let(:expected) { {} }

      it 'should serialize the hash' do
        expect(serializer.call(object, context: context))
          .to be == expected
      end
    end

    describe 'with a hash with invalid keys' do
      let(:object)        { { ichi: 1 } }
      let(:error_message) { 'object must be a Hash with String keys' }

      it 'should raise an exception' do
        expect { serializer.call(object, context: context) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a hash with many values' do
      let(:object) do
        {
          'count' => 4,
          'items' => 'lights'
        }
      end

      context 'when there are not matching serializers for any of the values' do
        let(:error_message) { 'no serializer defined for Integer' }

        it 'should raise an exception' do
          expect { serializer.call(object, context: context) }
            .to raise_error(
              Cuprum::Rails::Serializers::Context::UndefinedSerializerError,
              error_message
            )
        end
      end

      context 'when there are not matching serializers for all of the values' do
        let(:serializers) do
          {
            Integer => instance_double(described_class, call: 'int')
          }
        end
        let(:error_message) { 'no serializer defined for String' }

        it 'should raise an exception' do
          expect { serializer.call(object, context: context) }
            .to raise_error(
              Cuprum::Rails::Serializers::Context::UndefinedSerializerError,
              error_message
            )
        end
      end

      context 'when there are matching serializers for all of the values' do
        let(:serializers) do
          {
            Integer => instance_double(described_class, call: 'int'),
            String  => instance_double(described_class, call: 'str')
          }
        end
        let(:expected) do
          {
            'count' => 'int',
            'items' => 'str'
          }
        end

        it 'should serialize the hash' do
          expect(serializer.call(object, context: context))
            .to be == expected
        end
      end
    end

    describe 'with a hash of hashes' do
      let(:object) do
        {
          'spells' => {
            'epic' => {
              'name'  => "Karsus's Avatar",
              'level' => 13
            }
          }
        }
      end
      let(:serializers) do
        {
          Hash    => described_class.instance,
          Integer => instance_double(described_class, call: 'int'),
          String  => instance_double(described_class, call: 'str')
        }
      end
      let(:expected) do
        {
          'spells' => {
            'epic' => {
              'name'  => 'str',
              'level' => 'int'
            }
          }
        }
      end

      it 'should serialize the hash' do
        expect(serializer.call(object, context: context))
          .to be == expected
      end
    end
  end
end
