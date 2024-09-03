# frozen_string_literal: true

require 'cuprum/rails/serializers/context'

RSpec.describe Cuprum::Rails::Serializers::Context do
  subject(:context) { described_class.new(serializers:) }

  shared_context 'when initialized with serializers' do
    let(:cargo_serializer) { ->(_object, **_) {} }
    let(:serializers) do
      {
        Spec::RocketCargo  => cargo_serializer,
        Spec::RocketEngine => Spec::RocketEngineSerializer,
        Spec::RocketFuel   => Spec::RocketFuelSerializer,
        Spec::RocketPart   => Spec::RocketPartSerializer
      }
    end

    example_class 'Spec::Serializer' do |klass|
      klass.define_method(:call) { |_, **_| nil }
    end

    example_class 'Spec::RocketCargo'

    example_class 'Spec::FragileCargo', 'Spec::RocketCargo'

    example_class 'Spec::RocketPart'

    example_class 'Spec::RocketPartSerializer', 'Spec::Serializer'

    example_class 'Spec::RocketEngine', 'Spec::RocketPart'

    example_class 'Spec::RocketEngineSerializer', 'Spec::Serializer'

    example_class 'Spec::RocketExperiment', 'Spec::RocketPart'

    example_class 'Spec::RocketFuel'

    example_class 'Spec::NuclearFuel', 'Spec::RocketFuel'

    example_class 'Spec::RocketFuelSerializer', 'Spec::Serializer' do |klass|
      klass.define_singleton_method :instance do
        @instance ||= new
      end
    end
  end

  let(:serializers) { {} }

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

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:serializers)
    end
  end

  describe '#serialize' do
    shared_examples 'should serialize the object' do
      let(:serializer) { context.serializer_for(object) }
      let(:value) do
        "#{object.inspect} serialized by #{serializer.class.name}"
      end

      before(:example) { allow(serializer).to receive(:call).and_return(value) }

      it 'should call the serializer' do
        context.serialize(object)

        expect(serializer)
          .to have_received(:call)
          .with(object, context:)
      end

      it 'should return the serialized value' do
        expect(context.serialize(object)).to be value
      end
    end

    it { expect(context).to respond_to(:serialize).with(1).argument }

    describe 'with an object with no configured serializer' do
      let(:object) { Object.new.freeze }
      let(:error_message) do
        "no serializer defined for #{object.class.name}"
      end

      it 'should raise an exception' do
        expect { context.serialize(object) }
          .to raise_error(
            described_class::UndefinedSerializerError,
            error_message
          )
      end
    end

    wrap_context 'when initialized with serializers' do
      describe 'with an object with no configured serializer' do
        let(:object) { Object.new.freeze }
        let(:error_message) do
          "no serializer defined for #{object.class.name}"
        end

        it 'should raise an exception' do
          expect { context.serialize(object) }
            .to raise_error(
              described_class::UndefinedSerializerError,
              error_message
            )
        end
      end

      describe 'with an object with a configured serializer' do
        let(:object) { Spec::RocketCargo.new }

        include_examples 'should serialize the object'

        describe 'with a subclass' do
          let(:object) { Spec::FragileCargo.new }

          include_examples 'should serialize the object'
        end
      end

      describe 'with an object with a configured serializer class' do
        let(:object) { Spec::RocketPart.new }

        include_examples 'should serialize the object'

        describe 'with a subclass' do
          let(:object) { Spec::RocketExperiment.new }

          include_examples 'should serialize the object'
        end

        describe 'with a subclass with a configured serializer class' do
          let(:object) { Spec::RocketEngine.new }

          include_examples 'should serialize the object'
        end
      end

      describe 'with an object with an instanced serializer class' do
        let(:object) { Spec::RocketFuel.new }

        include_examples 'should serialize the object'

        describe 'with a subclass' do
          let(:object) { Spec::RocketExperiment.new }

          include_examples 'should serialize the object'
        end
      end
    end
  end

  describe '#serializer_for' do
    it { expect(context).to respond_to(:serializer_for).with(1).argument }

    describe 'with an object with no configured serializer' do
      let(:object) { Object.new.freeze }
      let(:error_message) do
        "no serializer defined for #{object.class.name}"
      end

      it 'should raise an exception' do
        expect { context.serializer_for(object) }
          .to raise_error(
            described_class::UndefinedSerializerError,
            error_message
          )
      end
    end

    wrap_context 'when initialized with serializers' do
      describe 'with an object with no configured serializer' do
        let(:object) { Object.new.freeze }
        let(:error_message) do
          "no serializer defined for #{object.class.name}"
        end

        it 'should raise an exception' do
          expect { context.serializer_for(object) }
            .to raise_error(
              described_class::UndefinedSerializerError,
              error_message
            )
        end
      end

      describe 'with an object with a configured serializer' do
        let(:object) { Spec::RocketCargo.new }

        it 'should return the configured serializer' do
          expect(context.serializer_for object).to be cargo_serializer
        end

        describe 'with a subclass' do
          let(:object) { Spec::FragileCargo.new }

          it 'should return the configured serializer' do
            expect(context.serializer_for object).to be cargo_serializer
          end
        end
      end

      describe 'with an object with a configured serializer class' do
        let(:object) { Spec::RocketPart.new }

        it 'should return an instance of the configured serializer' do
          expect(context.serializer_for object)
            .to be_a Spec::RocketPartSerializer
        end

        describe 'with a subclass' do
          let(:object) { Spec::RocketExperiment.new }

          it 'should return an instance of the configured serializer' do
            expect(context.serializer_for object)
              .to be_a Spec::RocketPartSerializer
          end
        end

        describe 'with a subclass with a configured serializer class' do
          let(:object) { Spec::RocketEngine.new }

          it 'should return an instance of the configured serializer' do
            expect(context.serializer_for object)
              .to be_a Spec::RocketEngineSerializer
          end
        end
      end

      describe 'with an object with an instanced serializer class' do
        let(:object) { Spec::RocketFuel.new }

        it 'should return an instance of the configured serializer' do
          expect(context.serializer_for object)
            .to be Spec::RocketFuelSerializer.instance
        end

        describe 'with a subclass' do
          let(:object) { Spec::NuclearFuel.new }

          it 'should return an instance of the configured serializer' do
            expect(context.serializer_for object)
              .to be_a Spec::RocketFuelSerializer
          end
        end
      end
    end
  end

  describe '#serializers' do
    include_examples 'should define reader',
      :serializers,
      -> { be == serializers }

    wrap_context 'when initialized with serializers' do
      it { expect(context.serializers).to be == serializers }
    end
  end
end
