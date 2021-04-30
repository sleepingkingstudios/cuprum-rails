# frozen_string_literal: true

require 'cuprum/rails/commands/assign_one'
require 'cuprum/rails/rspec/command_contract'
require 'cuprum/collections/rspec/assign_one_command_contract'

require 'support/examples/rails_command_examples'

RSpec.describe Cuprum::Rails::Commands::AssignOne do
  include Spec::Support::Examples::RailsCommandExamples

  include_context 'with parameters for a Rails command'

  subject(:command) do
    described_class.new(
      record_class: record_class,
      **constructor_options
    )
  end

  let(:initial_attributes)  { {} }
  let(:entity)              { Book.new(initial_attributes) }
  let(:expected_value)      { Book.new(expected_attributes) }
  let(:valid_attributes)    { record_class.column_names }

  include_contract Cuprum::Rails::RSpec::COMMAND_CONTRACT

  include_contract Cuprum::Collections::RSpec::ASSIGN_ONE_COMMAND_CONTRACT,
    allow_extra_attributes: false

  describe '#call' do
    include_examples 'should validate the :entity keyword'
  end
end
