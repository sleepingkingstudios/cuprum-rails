# frozen_string_literal: true

require 'stannum/errors'

require 'cuprum/rails/actions/create'

require 'support/book'
require 'support/examples/action_examples'
require 'support/tome'

RSpec.describe Cuprum::Rails::Actions::Create do
  include Spec::Support::Examples::ActionExamples

  subject(:action) { described_class.new(resource: resource) }

  let(:resource_class) { Book }
  let(:collection) do
    Cuprum::Rails::Collection.new(record_class: resource_class)
  end
  let(:permitted_attributes) do
    %i[title author series]
  end
  let(:resource) do
    Cuprum::Rails::Resource.new(
      collection:           collection,
      permitted_attributes: permitted_attributes,
      resource_class:       resource_class,
      **resource_options
    )
  end
  let(:resource_options) { {} }

  include_examples 'should define the ResourceAction methods'

  describe '#call' do
    let(:params)  { {} }
    let(:request) { instance_double(ActionDispatch::Request, params: params) }

    context 'when the resource does not define permitted attributes' do
      let(:permitted_attributes) { nil }
      let(:expected_error) do
        Cuprum::Rails::Errors::UndefinedPermittedAttributes
          .new(resource_name: resource.singular_resource_name)
      end

      it 'should return a failing result' do
        expect(action.call(request: request))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    context 'when the parameters do not include params for the resource' do
      let(:expected_error) do
        Cuprum::Rails::Errors::MissingParameters
          .new(resource_name: resource.singular_resource_name)
      end

      it 'should return a failing result' do
        expect(action.call(request: request))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    context 'when the resource params include extra attributes' do
      let(:permitted_attributes) { super() + %i[publisher] }
      let(:resource_params) do
        {
          title:     'Gideon the Ninth',
          author:    'Tammsyn Muir',
          publisher: 'Tor'
        }
      end
      let(:params) { { resource.singular_resource_name => resource_params } }
      let(:expected_error) do
        Cuprum::Collections::Errors::ExtraAttributes.new(
          entity_class:     resource.resource_class,
          extra_attributes: %w[publisher],
          valid_attributes: %w[id title author series category published_at]
        )
      end

      it 'should return a failing result' do
        expect(action.call(request: request))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    context 'when the resource params fail validation' do
      let(:resource_params) do
        {
          title:  'Gideon the Ninth',
          author: ''
        }
      end
      let(:params) { { resource.singular_resource_name => resource_params } }
      let(:expected_value) do
        {
          resource.singular_resource_name => resource_class.new(resource_params)
        }
      end
      let(:expected_error) do
        errors = Stannum::Errors.new
        errors[:author].add('blank', message: "can't be blank")

        Cuprum::Collections::Errors::FailedValidation.new(
          entity_class: resource.resource_class,
          errors:       errors
        )
      end

      it 'should return a failing result' do
        expect(action.call(request: request))
          .to be_a_failing_result
          .with_value(expected_value)
          .and_error(expected_error)
      end
    end

    context 'when the resource already exists' do
      let(:permitted_attributes) { %i[uuid] + super() }
      let(:resource_class)       { Tome }
      let(:resource_params) do
        {
          uuid:   '00000000-0000-0000-0000-000000000000',
          title:  'Harrow the Ninth',
          author: 'Tammsyn Muir'
        }
      end
      let(:params) { { resource.singular_resource_name => resource_params } }
      let(:expected_error) do
        Cuprum::Collections::Errors::AlreadyExists.new(
          collection_name:    resource.resource_name,
          primary_key_name:   :uuid,
          primary_key_values: resource_params[:uuid]
        )
      end

      before(:example) do
        resource_class.create!(
          uuid:   '00000000-0000-0000-0000-000000000000',
          title:  'Gideon the Ninth',
          author: 'Tammsyn Muir'
        )
      end

      it 'should return a failing result' do
        expect(action.call(request: request))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    context 'with valid parameters' do
      let(:resource_params) do
        {
          title:  'Harrow the Ninth',
          author: 'Tammsyn Muir'
        }
      end
      let(:params) { { resource.singular_resource_name => resource_params } }
      let(:record) do
        resource_class.where(resource_params).limit(1).first
      end
      let(:expected_value) do
        { resource.singular_resource_name => record }
      end

      it 'should return a passing result with the resource' do
        expect(action.call(request: request))
          .to be_a_passing_result
          .with_value(expected_value)
      end

      it 'should add the resource to the collection' do
        expect { action.call(request: request) }
          .to change(resource_class, :count)
          .by 1
      end
    end
  end
end
