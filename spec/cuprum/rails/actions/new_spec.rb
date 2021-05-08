# frozen_string_literal: true

require 'cuprum/rails/actions/new'

require 'support/book'
require 'support/examples/action_examples'

RSpec.describe Cuprum::Rails::Actions::New do
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
    let(:expected_value) do
      { resource.singular_resource_name => resource_class.new }
    end

    it 'should return a passing result' do
      expect(action.call(request: request))
        .to be_a_passing_result
        .with_value(expected_value)
    end
  end
end
