# frozen_string_literal: true

require 'cuprum/rails/serializers/json/serializer'

RSpec.describe Cuprum::Rails::Serializers::Json::Serializer do
  subject(:serializer) { described_class.new }

  describe '::RecursiveSerializerError' do
    it 'should define the error class' do
      expect(described_class)
        .to define_constant(:RecursiveSerializerError)
        .with_value(an_instance_of Class)
    end

    it 'should inherit from StandardError' do
      expect(described_class::RecursiveSerializerError).to be < StandardError
    end
  end

  describe '::UndefinedSerializerError' do
    it 'should define the error class' do
      expect(described_class)
        .to define_constant(:UndefinedSerializerError)
        .with_value(an_instance_of Class)
    end

    it 'should inherit from StandardError' do
      expect(described_class::UndefinedSerializerError).to be < StandardError
    end
  end

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
    let(:object)                 { nil }
    let(:part_serializer)        { serializer_for(Spec::Part) }
    let(:rocket_part_serializer) { serializer_for(Spec::RocketPart) }
    let(:serializers) do
      {
        Spec::Part       => part_serializer,
        Spec::RocketPart => rocket_part_serializer
      }
    end

    def serializer_for(klass)
      instance_double(described_class, call: { 'type' => klass.name })
    end

    it 'should define the method' do
      expect(serializer)
        .to respond_to(:call)
        .with(1).argument
        .and_keywords(:serializers)
    end

    example_class 'Spec::Part'

    example_class 'Spec::RocketPart', 'Spec::Part'

    example_class 'Spec::RocketEngine', 'Spec::RocketPart'

    context 'when the serializers are empty' do
      let(:serializers) { {} }
      let(:error_message) do
        'no serializer defined for NilClass'
      end

      it 'should raise an exception' do
        expect { serializer.call(object, serializers: serializers) }
          .to raise_error(
            described_class::UndefinedSerializerError,
            error_message
          )
      end
    end

    context 'when there is no serializer for the object' do
      let(:error_message) do
        'no serializer defined for NilClass'
      end

      it 'should raise an exception' do
        expect { serializer.call(object, serializers: serializers) }
          .to raise_error(
            described_class::UndefinedSerializerError,
            error_message
          )
      end
    end

    context 'when there is a serializer for the object class' do
      let(:object)   { Spec::RocketPart.new }
      let(:expected) { { 'type' => 'Spec::RocketPart' } }

      it 'should call the serializer' do
        serializer.call(object, serializers: serializers)

        expect(rocket_part_serializer)
          .to have_received(:call)
          .with(object, serializers: serializers)
      end

      it 'should serialize the object' do
        expect(serializer.call(object, serializers: serializers))
          .to be == expected
      end
    end

    context 'when there is a serializer for an object class ancestor' do
      let(:object)   { Spec::RocketEngine.new }
      let(:expected) { { 'type' => 'Spec::RocketPart' } }

      it 'should call the serializer' do
        serializer.call(object, serializers: serializers)

        expect(rocket_part_serializer)
          .to have_received(:call)
          .with(object, serializers: serializers)
      end

      it 'should serialize the object' do
        expect(serializer.call(object, serializers: serializers))
          .to be == expected
      end
    end

    context 'when the matching serializer is a instance of Json::Serializer' do
      let(:serializers) { { Object => Spec::Serializer.new } }
      let(:error_message) do
        'invalid serializer for NilClass - recursive calls to' \
          ' Spec::Serializer#call'
      end

      example_class 'Spec::Serializer', described_class

      it 'should raise an exception' do
        expect { serializer.call(object, serializers: serializers) }
          .to raise_error(
            described_class::RecursiveSerializerError,
            error_message
          )
      end
    end
  end
end
