# frozen_string_literal: true

require 'cuprum/rails/responders/serialization'

RSpec.describe Cuprum::Rails::Responders::Serialization do
  subject(:responder) { described_class.new(**constructor_options) }

  let(:described_class) { Spec::Responder }
  let(:root_serializer) { instance_double(Spec::Serializer, call: nil) }
  let(:serializers) do
    {
      Object => Spec::Serializer.new
    }
  end
  let(:constructor_options) do
    {
      root_serializer: root_serializer,
      serializers:     serializers
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
        .and_keywords(:root_serializer, :serializers)
        .and_any_keywords
    end
  end

  describe '#root_serializer' do
    include_examples 'should define reader',
      :root_serializer,
      -> { root_serializer }
  end

  describe '#serialize' do
    let(:object)  { Object.new.freeze }
    let(:value)   { 'serialized' }
    let(:context) { instance_double(Cuprum::Rails::Serializers::Context) }

    before(:example) do
      allow(Cuprum::Rails::Serializers::Context)
        .to receive(:new)
        .and_return(context)

      allow(root_serializer).to receive(:call).and_return(value)
    end

    it { expect(responder).to respond_to(:serialize).with(1).argument }

    it 'should build a serialization context' do
      responder.serialize(object)

      expect(Cuprum::Rails::Serializers::Context)
        .to have_received(:new)
        .with(serializers: serializers)
    end

    it 'should call the root serializer' do
      responder.serialize(object)

      expect(root_serializer)
        .to have_received(:call)
        .with(object, context: context)
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
