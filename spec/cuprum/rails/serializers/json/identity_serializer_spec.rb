# frozen_string_literal: true

require 'cuprum/rails/serializers/json/identity_serializer'

RSpec.describe Cuprum::Rails::Serializers::Json::IdentitySerializer do
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
    shared_examples 'should return the object' do
      it 'should return the object' do
        expect(serializer.call(object, context:)).to be object
      end

      context 'when there is a serializer for the object' do
        let(:serializers) do
          {
            object.class => instance_double(described_class, call: Object.new)
          }
        end

        it 'should return the object' do
          expect(serializer.call(object, context:)).to be object
        end
      end
    end

    let(:serializers) { {} }
    let(:context) do
      Cuprum::Rails::Serializers::Context.new(serializers:)
    end

    it 'should define the method' do
      expect(serializer)
        .to respond_to(:call)
        .with(1).argument
        .and_keywords(:serializers)
    end

    describe 'with nil' do
      let(:object) { nil }

      include_examples 'should return the object'
    end

    describe 'with an object' do
      let(:object) { Object.new.freeze }

      include_examples 'should return the object'
    end

    describe 'with false' do
      let(:object) { false }

      include_examples 'should return the object'
    end

    describe 'with true' do
      let(:object) { true }

      include_examples 'should return the object'
    end

    describe 'with a float' do
      let(:object) { 1.0 }

      include_examples 'should return the object'
    end

    describe 'with an integer' do
      let(:object) { 1 }

      include_examples 'should return the object'
    end

    describe 'with a string' do
      let(:object) { 'string' }

      include_examples 'should return the object'
    end
  end
end
