# frozen_string_literal: true

require 'cuprum/rails/responders/json/resource'
require 'cuprum/rails/rspec/deferred/responder_examples'
require 'cuprum/rails/rspec/deferred/responses/json_response_examples'

require 'support/book'

RSpec.describe Cuprum::Rails::Responders::Json::Resource do
  include Cuprum::Rails::RSpec::Deferred::ResponderExamples
  include Cuprum::Rails::RSpec::Deferred::Responses::JsonResponseExamples

  subject(:responder) { described_class.new(**constructor_options) }

  let(:serializers) { Cuprum::Rails::Serializers::Json.default_serializers }
  let(:constructor_options) do
    {
      action_name:,
      controller:,
      request:,
      serializers:
    }
  end

  include_deferred 'should implement the Responder methods',
    constructor_keywords: %i[matcher serializers]

  describe '#call' do
    describe 'with a failing result' do
      let(:error)    { Cuprum::Error.new(message: 'Something went wrong.') }
      let(:result)   { Cuprum::Result.new(status: :failure, error:) }
      let(:response) { responder.call(result) }
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

      include_deferred 'should render JSON',
        data:   -> { expected },
        status: 500

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

        include_deferred 'should render JSON',
          data:   -> { expected },
          status: 422
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

        include_deferred 'should render JSON',
          data:   -> { expected },
          status: 422
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

        include_deferred 'should render JSON',
          data:   -> { expected },
          status: 422
      end

      describe 'with an InvalidParameters error' do
        let(:error) do
          errors = Stannum::Errors.new.tap do |err|
            err['id'].add(Stannum::Constraints::Presence::TYPE)
          end

          Cuprum::Rails::Errors::InvalidParameters.new(errors:)
        end
        let(:expected) do
          {
            'ok'    => false,
            'error' => error.as_json
          }
        end

        include_deferred 'should render JSON',
          data:   -> { expected },
          status: 400
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

        include_deferred 'should render JSON',
          data:   -> { expected },
          status: 404
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
      let(:expected) do
        {
          'ok'   => true,
          'data' => data
        }
      end

      include_deferred 'should render JSON', data: -> { expected }

      describe 'with action_name: :create' do
        let(:action_name) { :create }

        include_deferred 'should render JSON',
          data:   -> { expected },
          status: 201
      end
    end
  end
end
