# frozen_string_literal: true

require 'cuprum/rails/serializers/base_serializer'
require 'cuprum/rails/serializers/context'

RSpec.describe Cuprum::Rails::Serializers::BaseSerializer do
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
    let(:context) do
      Cuprum::Rails::Serializers::Context.new(serializers: serializers)
    end

    example_class 'Spec::Part'

    example_class 'Spec::RocketPart', 'Spec::Part'

    example_class 'Spec::RocketEngine', 'Spec::RocketPart'

    def serializer_for(klass)
      instance_double(described_class, call: { 'type' => klass.name })
    end

    it 'should define the method' do
      expect(serializer)
        .to respond_to(:call)
        .with(1).argument
        .and_keywords(:context)
    end

    it 'should delegate to the context' do
      allow(context).to receive(:serialize)
      allow(context).to receive(:serializer_for)

      serializer.call(object, context: context)

      expect(context).to have_received(:serialize).with(object)
    end

    context 'when the serializers are empty' do
      let(:serializers) { {} }
      let(:error_message) do
        'no serializer defined for NilClass'
      end

      it 'should raise an exception' do
        expect { serializer.call(object, context: context) }
          .to raise_error(
            Cuprum::Rails::Serializers::Context::UndefinedSerializerError,
            error_message
          )
      end
    end

    context 'when there is no serializer for the object' do
      let(:error_message) { 'no serializer defined for NilClass' }

      it 'should raise an exception' do
        expect { serializer.call(object, context: context) }
          .to raise_error(
            Cuprum::Rails::Serializers::Context::UndefinedSerializerError,
            error_message
          )
      end
    end

    context 'when there is a serializer for the object class' do
      let(:object)   { Spec::RocketPart.new }
      let(:expected) { { 'type' => 'Spec::RocketPart' } }

      it 'should call the serializer' do
        serializer.call(object, context: context)

        expect(rocket_part_serializer)
          .to have_received(:call)
          .with(object, context: context)
      end

      it 'should serialize the object' do
        expect(serializer.call(object, context: context))
          .to be == expected
      end
    end

    context 'when there is a serializer for an object class ancestor' do
      let(:object)   { Spec::RocketEngine.new }
      let(:expected) { { 'type' => 'Spec::RocketPart' } }

      it 'should call the serializer' do
        serializer.call(object, context: context)

        expect(rocket_part_serializer)
          .to have_received(:call)
          .with(object, context: context)
      end

      it 'should serialize the object' do
        expect(serializer.call(object, context: context))
          .to be == expected
      end
    end

    context 'when the matching serializer is a instance of Json::Serializer' do
      let(:serializers) { { Object => Spec::Serializer.new } }
      let(:error_message) do
        'invalid serializer for NilClass - recursive calls to ' \
          'Spec::Serializer#call'
      end

      example_class 'Spec::Serializer', described_class

      it 'should raise an exception' do
        expect { serializer.call(object, context: context) }
          .to raise_error(
            described_class::RecursiveSerializerError,
            error_message
          )
      end
    end

    context 'with a recursive serializer subclass' do
      let(:described_class) { HeadTailSerializer }
      let(:serializers)     { { String => ->(str, **_) { str.upcase } } }
      let(:object)          { %w[ichi ni san] }
      let(:expected)        { %w[ICHI NI SAN] }

      example_class 'HeadTailSerializer', described_class do |klass|
        klass.define_method :call do |object, context:|
          return [] if object.empty?

          head, *tail = object

          [super(head, context: context), *call(tail, context: context)]
        end

        klass.define_method :allow_recursion? do
          true
        end
      end

      it 'should serialize the object' do
        expect(serializer.call(object, context: context))
          .to be == expected
      end
    end
  end
end
