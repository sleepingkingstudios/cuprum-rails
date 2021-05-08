# frozen_string_literal: true

require 'cuprum/rails/actions/resource_action'

require 'support/book'
require 'support/examples/action_examples'

RSpec.describe Cuprum::Rails::Actions::ResourceAction do
  include Spec::Support::Examples::ActionExamples

  subject(:action) { described_class.new(resource: resource) }

  let(:collection) { Cuprum::Rails::Collection.new(record_class: Book) }
  let(:resource) do
    Cuprum::Rails::Resource.new(
      collection:     collection,
      resource_class: Book,
      **resource_options
    )
  end
  let(:resource_options) { {} }

  include_examples 'should define the ResourceAction methods'
end
