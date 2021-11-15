# frozen_string_literal: true

require 'cuprum/rails/serializers/json/active_record_serializer'

require 'support/book'

RSpec.describe Cuprum::Rails::Serializers::Json::ActiveRecordSerializer do
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

    it 'should define the method' do
      expect(serializer)
        .to respond_to(:call)
        .with(1).argument
        .and_keywords(:serializers)
    end

    describe 'with nil' do
      let(:object)        { nil }
      let(:error_message) { 'object must be an ActiveRecord record' }

      it 'should raise an exception' do
        expect { serializer.call(object, serializers: serializers) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an Object' do
      let(:object)        { Object.new.freeze }
      let(:error_message) { 'object must be an ActiveRecord record' }

      it 'should raise an exception' do
        expect { serializer.call(object, serializers: serializers) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an ActiveRecord record' do
      let(:object) do
        Book.new(
          id:           0,
          title:        'Gideon the Ninth',
          author:       'Tamsyn Muir',
          series:       'The Locked Tomb',
          category:     'Science Fiction & Fantasy',
          published_at: '2019-09-10'
        )
      end
      let(:expected) do
        {
          'id'           => 0,
          'title'        => 'Gideon the Ninth',
          'author'       => 'Tamsyn Muir',
          'series'       => 'The Locked Tomb',
          'category'     => 'Science Fiction & Fantasy',
          'published_at' => '2019-09-10T00:00:00.000Z'
        }
      end

      it 'should serialize the record' do
        expect(serializer.call(object, serializers: serializers))
          .to be == expected
      end

      context 'when there is a serializer for the object' do
        let(:serializers) do
          {
            Book => instance_double(described_class, call: Object.new)
          }
        end

        it 'should return the object' do
          expect(serializer.call(object, serializers: serializers))
            .to be == expected
        end
      end
    end
  end
end
