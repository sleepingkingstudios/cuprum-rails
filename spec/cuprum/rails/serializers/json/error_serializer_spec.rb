# frozen_string_literal: true

require 'cuprum/rails/serializers/json/error_serializer'

RSpec.describe Cuprum::Rails::Serializers::Json::ErrorSerializer do
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
      let(:error_message) { 'object must be a Cuprum::Error' }

      it 'should raise an exception' do
        expect { serializer.call(object, serializers: serializers) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an object' do
      let(:object)        { Object.new.freeze }
      let(:error_message) { 'object must be a Cuprum::Error' }

      it 'should raise an exception' do
        expect { serializer.call(object, serializers: serializers) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a cuprum error' do
      let(:object) do
        Spec::Error.new(
          message:  'Unable to log out because you are not logged in.',
          type:     'spec.cant_log_out',
          error_id: '10T'
        )
      end
      let(:expected) { object.as_json }

      example_class 'Spec::Error', Cuprum::Error do |klass|
        klass.define_method(:error_id) do
          @comparable_properties[:error_id] # rubocop:disable RSpec/InstanceVariable
        end

        klass.define_method(:as_json_data) do
          { error_id: error_id }
        end
      end

      it 'should serialize the error' do
        expect(serializer.call object, serializers: serializers)
          .to be == object.as_json
      end
    end
  end
end
