# frozen_string_literal: true

require 'cuprum/rails/responders/json/resource'

require 'support/book'

RSpec.describe Cuprum::Rails::Responders::Json::Resource do
  subject(:responder) { described_class.new(**constructor_options) }

  let(:action_name)     { :published }
  let(:controller_name) { 'Spec::CustomController' }
  let(:resource)        { Cuprum::Rails::Resource.new(resource_name: 'books') }
  let(:serializers)     { Cuprum::Rails::Serializers::Json.default_serializers }
  let(:constructor_options) do
    {
      action_name:     action_name,
      controller_name: controller_name,
      resource:        resource,
      serializers:     serializers
    }
  end

  describe '.new' do
    let(:expected_keywords) do
      %i[
        action_name
        controller_name
        matcher
        member_action
        resource
        serializers
      ]
    end

    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(*expected_keywords)
        .and_any_keywords
    end
  end

  describe '#call' do
    it { expect(responder).to respond_to(:call).with(1).argument }

    describe 'with a failing result' do
      let(:error)    { Cuprum::Error.new(message: 'Something went wrong.') }
      let(:result)   { Cuprum::Result.new(status: :failure, error: error) }
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

      describe 'with an AlreadyExists error' do
        let(:error) do
          Cuprum::Collections::Errors::AlreadyExists.new(
            attribute_name:  :id,
            attribute_value: 0,
            collection_name: 'books',
            primary_key:     true
          )
        end
        let(:expected) do
          {
            'ok'    => false,
            'error' => error.as_json
          }
        end

        it { expect(response.data).to be == expected }

        it { expect(response.status).to be 422 }
      end

      describe 'with an ExtraAttributes error' do
        let(:error) do
          Cuprum::Collections::Errors::ExtraAttributes.new(
            entity_class:     Book,
            extra_attributes: %w[banned_at],
            valid_attributes: %w[id title author series category published_at]
          )
        end
        let(:expected) do
          {
            'ok'    => false,
            'error' => error.as_json
          }
        end

        it { expect(response.data).to be == expected }

        it { expect(response.status).to be 422 }
      end

      describe 'with a FailedValidation error' do
        let(:error) do
          Cuprum::Collections::Errors::FailedValidation.new(
            entity_class: Book,
            errors:       Stannum::Errors.new
          )
        end
        let(:expected) do
          {
            'ok'    => false,
            'error' => error.as_json
          }
        end

        it { expect(response.data).to be == expected }

        it { expect(response.status).to be 422 }
      end

      describe 'with an InvalidParameters error' do
        let(:error) do
          errors = Stannum::Errors.new.tap do |err|
            err['id'].add(Stannum::Constraints::Presence::TYPE)
          end

          Cuprum::Rails::Errors::InvalidParameters.new(errors: errors)
        end
        let(:expected) do
          {
            'ok'    => false,
            'error' => error.as_json
          }
        end

        it { expect(response.data).to be == expected }

        it { expect(response.status).to be 400 }
      end

      describe 'with a NotFound error' do
        let(:error) do
          Cuprum::Collections::Errors::NotFound.new(
            attribute_name:  :id,
            attribute_value: 0,
            collection_name: 'books',
            primary_key:     true
          )
        end
        let(:expected) do
          {
            'ok'    => false,
            'error' => error.as_json
          }
        end

        it { expect(response.data).to be == expected }

        it { expect(response.status).to be 404 }
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
      let(:result)   { Cuprum::Result.new(status: :success, value: value) }
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

      describe 'with action_name: :create' do
        let(:action_name) { :create }

        it { expect(response.data).to be == expected }

        it { expect(response.status).to be 201 }
      end
    end
  end
end
