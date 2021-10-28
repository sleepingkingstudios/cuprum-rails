# frozen_string_literal: true

require 'cuprum/rails/controllers/class_methods/configuration'
require 'cuprum/rails/controllers/class_methods/validations'
require 'cuprum/rails/controllers/configuration'
require 'cuprum/rails/resource'

RSpec.describe Cuprum::Rails::Controllers::Configuration do
  subject(:configuration) { described_class.new(controller) }

  let(:resource) { instance_double(Cuprum::Rails::Resource) }
  let(:responders) do
    { json: Spec::JsonResponder }
  end
  let(:serializers) do
    { Object => Spec::JsonSerializer }
  end
  let(:controller) do
    instance_double(
      Spec::Controller,
      resource:    resource,
      responders:  responders,
      serializers: serializers
    )
  end

  example_class 'Spec::Controller',
    Struct.new(:resource, :responders, :serializers)

  example_class 'Spec::JsonResponder'

  example_class 'Spec::JsonSerializer'

  describe '.new' do
    it { expect(described_class).to respond_to(:new).with(1).argument }
  end

  describe '#controller' do
    include_examples 'should define reader', :controller, -> { controller }
  end

  describe '#resource' do
    include_examples 'should define reader', :resource, -> { resource }
  end

  describe '#responder_for' do
    let(:error_class) do
      Cuprum::Rails::Controller::UnknownFormatError
    end
    let(:error_message) do
      "no responder registered for format #{format.inspect}"
    end

    it { expect(configuration).to respond_to(:responder_for).with(1).argument }

    describe 'with nil' do
      let(:format) { nil }

      it 'should raise an exception' do
        expect { configuration.responder_for(format) }
          .to raise_error error_class, error_message
      end
    end

    describe 'with an invalid format' do
      let(:format) { :xml }

      it 'should raise an exception' do
        expect { configuration.responder_for(format) }
          .to raise_error error_class, error_message
      end
    end

    describe 'with a valid format' do
      let(:format) { :json }

      it 'should return the configurated responder' do
        expect(configuration.responder_for(:json)).to be Spec::JsonResponder
      end
    end
  end

  describe '#responders' do
    include_examples 'should define reader', :responders, -> { responders }
  end

  describe '#serializers' do
    include_examples 'should define reader', :serializers, -> { serializers }
  end
end
