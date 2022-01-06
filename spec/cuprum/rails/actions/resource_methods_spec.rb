# frozen_string_literal: true

require 'cuprum/rails/actions/resource_action'

require 'support/book'
require 'support/examples/action_examples'

RSpec.describe Cuprum::Rails::Actions::ResourceMethods do
  include Spec::Support::Examples::ActionExamples

  subject(:action) { described_class.new(resource: resource) }

  let(:described_class) { Spec::Action }
  let(:collection)      { Cuprum::Rails::Collection.new(record_class: Book) }
  let(:resource) do
    Cuprum::Rails::Resource.new(
      collection:     collection,
      resource_class: Book,
      **resource_options
    )
  end
  let(:resource_options) { {} }

  example_class 'Spec::Action', Cuprum::Rails::Action do |klass|
    klass.include Cuprum::Rails::Actions::ResourceMethods # rubocop:disable RSpec/DescribedClass
  end

  include_examples 'should define the ResourceAction methods'
end
