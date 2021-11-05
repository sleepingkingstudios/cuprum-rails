# frozen_string_literal: true

require 'cuprum/rails/actions/edit'

require 'support/book'
require 'support/examples/action_examples'

RSpec.describe Cuprum::Rails::Actions::Edit do
  include Spec::Support::Examples::ActionExamples

  subject(:action) { described_class.new(resource: resource) }

  let(:resource_class) { Book }
  let(:collection) do
    Cuprum::Rails::Collection.new(record_class: resource_class)
  end
  let(:resource) do
    Cuprum::Rails::Resource.new(
      collection:     collection,
      resource_class: resource_class,
      **resource_options
    )
  end
  let(:resource_options) { {} }

  include_examples 'should define the ResourceAction methods'

  describe '#call' do
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

    context 'when the resource does not exist' do
      let(:primary_key_value) { 0 }
      let(:params)            { { id: primary_key_value } }
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

    context 'when the resource exists' do
      let(:record) do
        resource_class.create!(
          title:  'Gideon the Ninth',
          author: 'Tamsyn Muir'
        )
      end
      let(:primary_key_value) { record.id }
      let(:params)            { { id: primary_key_value } }

      it 'should return a passing result' do
        expect(action.call(request: request))
          .to be_a_passing_result
          .with_value({ resource.singular_resource_name => record })
      end
    end
  end
end
