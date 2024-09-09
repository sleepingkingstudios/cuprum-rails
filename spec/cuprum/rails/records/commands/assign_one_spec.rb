# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/commands/assign_one_examples'

require 'cuprum/rails/records/commands/assign_one'

require 'support/examples/records/command_examples'

RSpec.describe Cuprum::Rails::Records::Commands::AssignOne do
  include Cuprum::Collections::RSpec::Deferred::Commands::AssignOneExamples
  include Spec::Support::Examples::Records::CommandExamples

  subject(:command) { described_class.new(collection:) }

  let(:initial_attributes)  { {} }
  let(:entity)              { Book.new(initial_attributes) }
  let(:expected_value)      { Book.new(expected_attributes) }
  let(:valid_attributes)    { entity_class.column_names }

  include_deferred 'with parameters for a records command'

  include_deferred 'should implement the Records::Command methods'

  include_deferred 'should implement the AssignOne command',
    allow_extra_attributes: false
end
