# frozen_string_literal: true

require 'cuprum/rails/responders/json_responder'
require 'cuprum/rails/rspec/contracts/responder_contracts'
require 'cuprum/rails/serializers/json/active_record_serializer'

require 'support/book'

RSpec.describe Cuprum::Rails::Responders::JsonResponder do
  include Cuprum::Rails::RSpec::Contracts::ResponderContracts

  subject(:responder) { described_class.new(**constructor_options) }

  shared_context 'with a custom error' do
    let(:error) do
      Spec::Error.new(
        message:  'Unable to log out because you are not logged in.',
        type:     'spec.cant_log_out',
        error_id: '10T'
      )
    end

    example_class 'Spec::Error', Cuprum::Error do |klass|
      klass.define_method(:error_id) do
        @comparable_properties[:error_id] # rubocop:disable RSpec/InstanceVariable
      end

      klass.define_method(:as_json_data) do
        { error_id: }
      end
    end
  end

  let(:action_name) { :published }
  let(:controller)  { Spec::CustomController.new }
  let(:request)     { Cuprum::Rails::Request.new }
  let(:serializers) { Cuprum::Rails::Serializers::Json.default_serializers }
  let(:constructor_options) do
    {
      action_name:,
      controller:,
      request:,
      serializers:
    }
  end

  it { expect(described_class).to be < Cuprum::Rails::Responders::Actions }

  it { expect(described_class).to be < Cuprum::Rails::Responders::Matching }

  it 'should include the serialization implementation' do
    expect(described_class).to be < Cuprum::Rails::Responders::Serialization
  end

  include_contract 'should implement the responder methods',
    constructor_keywords: %i[matcher serializers]

  describe '#call' do
    describe 'with nil' do
      let(:error_message) { 'result must be a Cuprum::Result' }

      it 'should raise an exception' do
        expect { responder.call(nil) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an Object' do
      let(:error_message) { 'result must be a Cuprum::Result' }

      it 'should raise an exception' do
        expect { responder.call(Object.new.freeze) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a failing result' do
      let(:error)    { Cuprum::Error.new(message: 'Something went wrong.') }
      let(:result)   { Cuprum::Result.new(status: :failure, error:) }
      let(:response) { responder.call(result) }
      let(:response_class) do
        Cuprum::Rails::Responses::JsonResponse
      end
      let(:generic_error) do
        Cuprum::Error.new(
          message: 'Something went wrong when processing the request'
        )
      end
      let(:expected) do
        {
          'ok'    => false,
          'error' => generic_error.as_json
        }
      end

      it { expect(response).to be_a response_class }

      it { expect(response.data).to be == expected }

      it { expect(response.status).to be 500 }

      context 'when the environment is development' do
        let(:expected) do
          {
            'ok'    => false,
            'error' => error.as_json
          }
        end

        before(:example) do
          allow(Rails.env).to receive(:development?).and_return(true)
        end

        it { expect(response).to be_a response_class }

        it { expect(response.data).to be == expected }

        it { expect(response.status).to be 500 }
      end

      context 'with a subclass with custom generic error' do
        let(:described_class) { Spec::ExampleResponder }
        let(:generic_error) do
          Cuprum::Error.new(
            message: 'The magic smoke is escaping!',
            type:    'spec.example_error'
          )
        end
        let(:expected) do
          {
            'ok'    => false,
            'error' => generic_error.as_json
          }
        end

        # rubocop:disable RSpec/DescribedClass
        example_class 'Spec::ExampleResponder',
          Cuprum::Rails::Responders::JsonResponder \
        do |klass|
          klass.define_method(:generic_error) do
            Cuprum::Error.new(
              message: 'The magic smoke is escaping!',
              type:    'spec.example_error'
            )
          end
        end
        # rubocop:enable RSpec/DescribedClass

        it { expect(response).to be_a response_class }

        it { expect(response.data).to be == expected }

        it { expect(response.status).to be 500 }
      end
    end

    describe 'with a passing result' do
      let(:data) do
        {
          'weapons' => {
            'swords' => %w[daito shoto tachi]
          }
        }
      end
      let(:value)    { data }
      let(:result)   { Cuprum::Result.new(status: :success, value:) }
      let(:response) { responder.call(result) }
      let(:response_class) do
        Cuprum::Rails::Responses::JsonResponse
      end
      let(:expected) do
        {
          'ok'   => true,
          'data' => data
        }
      end

      it { expect(response).to be_a response_class }

      it { expect(response.data).to be == expected }

      it { expect(response.status).to be 200 }

      describe 'with a record value' do
        let(:serializers) do
          serializer =
            Cuprum::Rails::Serializers::Json::ActiveRecordSerializer.instance

          super().merge(Book => serializer)
        end
        let(:value) do
          Book.new(
            title:  'Gideon the Ninth',
            author: 'Tamsyn Muir'
          )
        end
        let(:data) { value.attributes }

        it { expect(response.data).to be == expected }
      end

      describe 'with an unserializable value' do
        let(:error_class) do
          Cuprum::Rails::Serializers::Context::UndefinedSerializerError
        end
        let(:error_message) do
          'no serializer defined for Object'
        end
        let(:value) { Object.new.freeze }

        it 'should raise an exception' do
          expect { responder.call(result) }
            .to raise_error(error_class, error_message)
        end
      end
    end
  end

  describe '#format' do
    include_examples 'should define reader', :format, :json
  end

  describe '#generic_error' do
    let(:generic_error) do
      Cuprum::Error.new(
        message: 'Something went wrong when processing the request'
      )
    end

    include_examples 'should define reader',
      :generic_error,
      -> { be == generic_error }
  end

  describe '#render' do
    let(:data) do
      {
        'weapons' => {
          'swords' => %w[daito shoto tachi]
        }
      }
    end
    let(:value)    { data }
    let(:options)  { {} }
    let(:response) { responder.render(value, **options) }
    let(:response_class) do
      Cuprum::Rails::Responses::JsonResponse
    end

    it 'should define the method' do
      expect(responder)
        .to respond_to(:render)
        .with(1).argument
        .and_keywords(:status)
    end

    it 'should serialize the data' do
      allow(responder).to receive(:serialize).and_call_original # rubocop:disable RSpec/SubjectStub

      responder.render(value, **options)

      expect(responder).to have_received(:serialize).with(value) # rubocop:disable RSpec/SubjectStub
    end

    it { expect(response).to be_a response_class }

    it { expect(response.data).to be == data }

    it { expect(response.status).to be 200 }

    describe 'with a record value' do
      let(:serializers) do
        serializer =
          Cuprum::Rails::Serializers::Json::ActiveRecordSerializer.instance

        super().merge(Book => serializer)
      end
      let(:value) do
        Book.new(
          title:  'Gideon the Ninth',
          author: 'Tamsyn Muir'
        )
      end
      let(:data) { value.attributes }

      it { expect(response.data).to be == data }
    end

    describe 'with an unserializable value' do
      let(:error_class) do
        Cuprum::Rails::Serializers::Context::UndefinedSerializerError
      end
      let(:error_message) do
        'no serializer defined for Object'
      end
      let(:value) { Object.new.freeze }

      it 'should raise an exception' do
        expect { responder.render(value, **options) }
          .to raise_error(error_class, error_message)
      end
    end

    describe 'with status: value' do
      let(:options) { super().merge(status: 422) }

      it { expect(response.status).to be 422 }
    end
  end

  describe '#render_failure' do
    include_context 'with a custom error'

    let(:options)  { {} }
    let(:response) { responder.render_failure(error, **options) }
    let(:response_class) do
      Cuprum::Rails::Responses::JsonResponse
    end
    let(:expected) do
      {
        'ok'    => false,
        'error' => error.as_json
      }
    end

    it 'should define the method' do
      expect(responder)
        .to respond_to(:render_failure)
        .with(1).argument
        .and_keywords(:status)
    end

    it { expect(response).to be_a response_class }

    it { expect(response.data).to be == expected }

    it { expect(response.status).to be 500 }

    describe 'with status: value' do
      let(:options) { super().merge(status: 422) }

      it { expect(response.status).to be 422 }
    end
  end

  describe '#render_success' do
    let(:data) do
      {
        'weapons' => {
          'swords' => %w[daito shoto tachi]
        }
      }
    end
    let(:value)    { data }
    let(:options)  { {} }
    let(:response) { responder.render_success(value, **options) }
    let(:response_class) do
      Cuprum::Rails::Responses::JsonResponse
    end
    let(:expected) do
      {
        'ok'   => true,
        'data' => data
      }
    end

    it 'should define the method' do
      expect(responder)
        .to respond_to(:render_success)
        .with(1).argument
        .and_keywords(:status)
    end

    it { expect(response).to be_a response_class }

    it { expect(response.data).to be == expected }

    it { expect(response.status).to be 200 }

    describe 'with a record value' do
      let(:serializers) do
        serializer =
          Cuprum::Rails::Serializers::Json::ActiveRecordSerializer.instance

        super().merge(Book => serializer)
      end
      let(:value) do
        Book.new(
          title:  'Gideon the Ninth',
          author: 'Tamsyn Muir'
        )
      end
      let(:data) { value.attributes }

      it { expect(response.data).to be == expected }
    end

    describe 'with an unserializable value' do
      let(:error_class) do
        Cuprum::Rails::Serializers::Context::UndefinedSerializerError
      end
      let(:error_message) do
        'no serializer defined for Object'
      end
      let(:value) { Object.new.freeze }

      it 'should raise an exception' do
        expect { responder.render_success(value, **options) }
          .to raise_error(error_class, error_message)
      end
    end

    describe 'with status: value' do
      let(:options) { super().merge(status: 201) }

      it { expect(response.status).to be 201 }
    end
  end

  describe '#serializers' do
    include_examples 'should define reader',
      :serializers,
      -> { be == serializers }
  end
end
