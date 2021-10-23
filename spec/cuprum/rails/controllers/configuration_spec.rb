# frozen_string_literal: true

require 'cuprum/rails/controllers/configuration'
require 'cuprum/rails/resource'

RSpec.describe Cuprum::Rails::Controllers::Configuration do
  subject(:configuration) do
    described_class.new(
      resource:   resource,
      responders: responders
    )
  end

  let(:resource) { instance_double(Cuprum::Rails::Resource) }
  let(:responders) do
    { json: Spec::JsonResponder }
  end

  example_class 'Spec::JsonResponder'

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:resource, :responders)
    end
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
end
