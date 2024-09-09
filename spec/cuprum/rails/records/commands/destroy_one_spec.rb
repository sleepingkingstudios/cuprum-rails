# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/commands/destroy_one_examples'

require 'cuprum/rails/records/commands/destroy_one'

require 'support/examples/records/command_examples'

RSpec.describe Cuprum::Rails::Records::Commands::DestroyOne do
  include Cuprum::Collections::RSpec::Deferred::Commands::DestroyOneExamples
  include Spec::Support::Examples::Records::CommandExamples

  subject(:command) { described_class.new(collection:) }

  let(:expected_data) { record_class.new(matching_data) }

  include_deferred 'with parameters for a records command'

  include_deferred 'should implement the Records::Command methods'

  include_deferred 'should implement the DestroyOne command'

  wrap_deferred 'with a collection with a custom primary key' do
    include_deferred 'should implement the DestroyOne command'
  end
end
