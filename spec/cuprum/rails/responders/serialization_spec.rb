# frozen_string_literal: true

require 'cuprum/rails/responders/serialization'

RSpec.describe Cuprum::Rails::Responders::Serialization do
  subject(:responder) { described_class.new(**constructor_options) }

  let(:described_class) { Spec::Responder }
  let(:serializers) do
    {
      Object => Spec::Serializer.new
    }
  end
  let(:constructor_options) do
    {
      serializers:
    }
  end

  example_class 'Spec::BaseResponder' do |klass|
    klass.define_method(:initialize) { |**_| nil }
  end

  example_class 'Spec::Responder', 'Spec::BaseResponder' do |klass|
    klass.include Cuprum::Rails::Responders::Serialization # rubocop:disable RSpec/DescribedClass
  end

  example_class 'Spec::Serializer' do |klass|
    klass.define_method(:call) { |*_, **_| nil }
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:serializers)
        .and_any_keywords
    end
  end

  describe '#serialize' do
    let(:object)  { Object.new.freeze }
    let(:value)   { 'serialized' }
    let(:context) { instance_double(Cuprum::Rails::Serializers::Context) }
    let(:base_serializer) do
      instance_double(
        Cuprum::Rails::Serializers::BaseSerializer,
        call: value
      )
    end

    before(:example) do
      allow(Cuprum::Rails::Serializers::BaseSerializer)
        .to receive(:instance)
        .and_return(base_serializer)

      allow(Cuprum::Rails::Serializers::Context)
        .to receive(:new)
        .and_return(context)
    end

    it { expect(responder).to respond_to(:serialize).with(1).argument }

    it 'should build a serialization context' do
      responder.serialize(object)

      expect(Cuprum::Rails::Serializers::Context)
        .to have_received(:new)
        .with(serializers:)
    end

    it 'should call the base serializer' do
      responder.serialize(object)

      expect(base_serializer)
        .to have_received(:call)
        .with(object, context:)
    end

    it 'should return the serialized value' do
      expect(responder.serialize object).to be == value
    end
  end

  describe '#serializers' do
    include_examples 'should define reader',
      :serializers,
      -> { be == serializers }
  end
end
