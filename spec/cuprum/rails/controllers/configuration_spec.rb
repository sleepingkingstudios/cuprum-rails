# frozen_string_literal: true

require 'cuprum/collections/repository'

require 'cuprum/rails/controllers/class_methods/configuration'
require 'cuprum/rails/controllers/class_methods/validations'
require 'cuprum/rails/controllers/configuration'
require 'cuprum/rails/controllers/middleware'
require 'cuprum/rails/resource'

RSpec.describe Cuprum::Rails::Controllers::Configuration do
  subject(:configuration) { described_class.new(controller) }

  let(:default_format) { :json }
  let(:resource)       { instance_double(Cuprum::Rails::Resource) }
  let(:middleware) do
    [
      Cuprum::Rails::Controllers::Middleware.new(command: Cuprum::Command.new)
    ]
  end
  let(:repository) do
    Cuprum::Collections::Repository.new
  end
  let(:responders) do
    { json: Spec::JsonResponder }
  end
  let(:serializers) do
    { Object => Spec::JsonSerializer }
  end
  let(:controller_name) { 'api/books' }
  let(:controller) do
    instance_double(
      Spec::Controller,
      controller_name:,
      default_format:,
      middleware:,
      repository:,
      resource:,
      responders:,
      serializers:
    )
  end

  example_class 'Spec::Controller',
    Struct.new(
      :controller_name,
      :default_format,
      :middleware,
      :repository,
      :resource,
      :responders,
      :serializers
    )

  example_class 'Spec::JsonResponder'

  example_class 'Spec::JsonSerializer'

  describe '.new' do
    it { expect(described_class).to respond_to(:new).with(1).argument }
  end

  describe '#controller' do
    include_examples 'should define reader', :controller, -> { controller }
  end

  describe '#controller_name' do
    include_examples 'should define reader',
      :controller_name,
      -> { controller_name }
  end

  describe '#default_format' do
    include_examples 'should define reader',
      :default_format,
      -> { default_format }
  end

  describe '#middleware' do
    include_examples 'should define reader', :middleware, -> { middleware }
  end

  describe '#middleware_for' do
    let(:action_name) { :publish }
    let(:request) do
      Cuprum::Rails::Request.new(action_name:)
    end

    it { expect(configuration).to respond_to(:middleware_for).with(1).argument }

    context 'when the controller does not define middleware' do
      let(:middleware) { [] }

      it { expect(configuration.middleware_for(request)).to be == [] }
    end

    context 'when the controller defines middleware' do
      let(:middleware) do
        [
          {
            command: Cuprum::Command.new
          },
          {
            command: Cuprum::Command.new,
            actions: { except: %i[index show] }
          },
          {
            command: Cuprum::Command.new,
            actions: { except: %i[draft publish] }
          },
          {
            command: Cuprum::Command.new,
            actions: { only: %i[create update] }
          },
          {
            command: Cuprum::Command.new,
            actions: { only: %i[approve publish] }
          }
        ]
          .map { |options| build_middleware(**options) }
      end
      let(:expected) do
        middleware.select { |item| item.matches?(request) }
      end

      def build_middleware(command:, actions: nil, **options)
        if actions
          actions =
            Cuprum::Rails::Controllers::Middleware::InclusionMatcher
              .build(actions)
        end

        Cuprum::Rails::Controllers::Middleware.new(
          actions:,
          command:,
          **options
        )
      end

      it { expect(configuration.middleware_for(request)).to be == expected }
    end
  end

  describe '#repository' do
    include_examples 'should define reader', :repository, -> { repository }
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

  describe '#serializers_for' do
    it { expect(configuration).to respond_to(:responder_for).with(1).argument }

    it { expect(configuration.serializers_for(:json)).to be == serializers }

    it { expect(configuration.serializers_for(:xml)).to be == serializers }

    context 'when initialized with scoped serializers' do
      let(:serializers) do
        {
          Object => Spec::JsonSerializer,
          json:     {
            Numeric => Spec::NumericSerializer,
            String  => Spec::StringSerializer
          }
        }
      end
      let(:json_serializers) do
        {
          Numeric => Spec::NumericSerializer,
          Object  => Spec::JsonSerializer,
          String  => Spec::StringSerializer
        }
      end
      let(:xml_serializers) do
        {
          Object => Spec::JsonSerializer
        }
      end

      example_class 'Spec::NumericSerializer'

      example_class 'Spec::StringSerializer'

      it 'should merge the serializers for the requested format' do
        expect(configuration.serializers_for(:json)).to be == json_serializers
      end

      it 'should return the default serializers' do
        expect(configuration.serializers_for(:xml)).to be == xml_serializers
      end
    end
  end
end
