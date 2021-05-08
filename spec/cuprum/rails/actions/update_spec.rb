# frozen_string_literal: true

require 'cuprum/rails/actions/update'

require 'support/book'
require 'support/examples/action_examples'

RSpec.describe Cuprum::Rails::Actions::Update do
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
    shared_context 'when the resource exists' do
      let!(:record) do
        resource_class.create!(
          title:  'Gideon the Ninth',
          author: 'Tammsyn Muir'
        )
      end
      let(:primary_key_value) { record.id }
      let(:params) do
        {
          'id'                            => primary_key_value,
          resource.singular_resource_name => resource_params
        }
      end
    end

    let(:params)  { {} }
    let(:request) { instance_double(ActionDispatch::Request, params: params) }

    context 'when the parameters do not include a primary key' do
      let(:expected_error) do
        Cuprum::Rails::Errors::MissingPrimaryKey.new(
          primary_key:   resource.primary_key,
          resource_name: resource.singular_resource_name
        )
      end

      it 'should return a failing result' do
        expect(action.call(request: request))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    context 'when the resource does not define permitted attributes' do
      let(:primary_key_value)    { 0 }
      let(:permitted_attributes) { nil }
      let(:params)               { { id: primary_key_value } }
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
      let(:primary_key_value) { 0 }
      let(:params)            { { id: primary_key_value } }
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

    context 'when the resource does not exist' do
      let(:primary_key_value) { 0 }
      let(:resource_params) do
        {
          title:  'Gideon the Ninth',
          author: 'Tammsyn Muir'
        }
      end
      let(:params) do
        {
          id:                                primary_key_value,
          resource.singular_resource_name => resource_params
        }
      end
      let(:expected_error) do
        Cuprum::Collections::Errors::NotFound.new(
          collection_name:    resource.resource_name,
          primary_key_name:   resource.primary_key,
          primary_key_values: primary_key_value
        )
      end

      it 'should return a failing result' do
        expect(action.call(request: request))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    context 'when the resource params include extra attributes' do
      include_context 'when the resource exists'

      let(:permitted_attributes) { super() + %i[publisher] }
      let(:resource_params) do
        {
          title:     'Gideon the Ninth',
          author:    'Tammsyn Muir',
          publisher: 'Tor'
        }
      end
      let(:expected_error) do
        Cuprum::Collections::Errors::ExtraAttributes.new(
          entity_class:     resource.resource_class,
          extra_attributes: %w[publisher],
          valid_attributes: %w[id title author series category]
        )
      end

      it 'should return a failing result' do
        expect(action.call(request: request))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    context 'when the resource params fail validation' do
      include_context 'when the resource exists'

      let(:resource_params) do
        {
          title:  'Gideon the Ninth',
          author: ''
        }
      end
      let(:expected_value) do
        assigned_record = record.tap do
          record.assign_attributes(resource_params)
        end

        { resource.singular_resource_name => assigned_record }
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

      it 'should not update the entity' do
        expect { action.call(request: request) }
          .not_to(change { record.reload.attributes })
      end
    end

    context 'with valid parameters' do
      include_context 'when the resource exists'

      let(:resource_params) do
        {
          title:  'Harrow the Ninth',
          author: 'Tammsyn Muir'
        }
      end
      let(:expected_value) do
        updated_record = record.tap do
          record.assign_attributes(resource_params)
        end

        { resource.singular_resource_name => updated_record }
      end

      it 'should return a passing result with the resource' do
        expect(action.call(request: request))
          .to be_a_passing_result
          .with_value(expected_value)
      end

      it 'should update the entity' do
        expect { action.call(request: request) }
          .to(
            change { record.reload.attributes }
            .to be > resource_params.stringify_keys
          )
      end
    end
  end
end
