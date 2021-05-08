# frozen_string_literal: true

require 'cuprum/collections/rspec/fixtures'

require 'cuprum/rails/actions/index'

require 'support/book'
require 'support/examples/action_examples'

RSpec.describe Cuprum::Rails::Actions::Index do
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
    let(:data)    { [] }
    let(:matching_data) do
      resource_class.all
    end
    let(:expected_value) do
      { resource.resource_name => matching_data.to_a }
    end

    before(:example) do
      data.each do |attributes|
        resource_class.create!(attributes.except('id'))
      end
    end

    it 'should return a passing result with the matching data' do
      expect(action.call(request: request))
        .to be_a_passing_result
        .with_value(expected_value)
    end

    context 'when the collection has many items' do
      let(:data) { Cuprum::Collections::RSpec::BOOKS_FIXTURES }

      it 'should return a passing result with the matching data' do
        expect(action.call(request: request))
          .to be_a_passing_result
          .with_value(expected_value)
      end

      context 'when the resource has a default order' do
        let(:default_order) { { author: :asc, title: :asc } }
        let(:resource_options) do
          super().merge(default_order: default_order)
        end
        let(:matching_data) do
          super().order(default_order)
        end

        it 'should return a passing result with the matching data' do
          expect(action.call(request: request))
            .to be_a_passing_result
            .with_value(expected_value)
        end
      end
    end
  end
end
