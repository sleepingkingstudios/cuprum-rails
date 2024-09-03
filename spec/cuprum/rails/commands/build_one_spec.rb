# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/command_contracts'

require 'cuprum/rails/commands/build_one'
require 'cuprum/rails/rspec/contracts/command_contracts'

require 'support/examples/rails_command_examples'

RSpec.describe Cuprum::Rails::Commands::BuildOne do
  include Cuprum::Collections::RSpec::Contracts::CommandContracts
  include Cuprum::Rails::RSpec::Contracts::CommandContracts
  include Spec::Support::Examples::RailsCommandExamples

  include_context 'with parameters for a Rails command'

  subject(:command) do
    described_class.new(
      record_class:,
      **constructor_options
    )
  end

  let(:expected_value)   { Book.new(expected_attributes) }
  let(:valid_attributes) { Book.attribute_names }

  include_contract 'should be a rails command'

  include_contract 'should be a build one command',
    allow_extra_attributes: false
end
