# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/commands/build_one_examples'

require 'cuprum/rails/records/commands/build_one'

require 'support/examples/records/command_examples'

RSpec.describe Cuprum::Rails::Records::Commands::BuildOne do
  include Cuprum::Collections::RSpec::Deferred::Commands::BuildOneExamples
  include Spec::Support::Examples::Records::CommandExamples

  subject(:command) { described_class.new(collection:) }

  let(:expected_value)   { Book.new(expected_attributes) }
  let(:valid_attributes) { Book.attribute_names }

  include_deferred 'with parameters for a records command'

  include_deferred 'should implement the Records::Command methods'

  include_deferred 'should implement the BuildOne command',
    allow_extra_attributes: false
end
