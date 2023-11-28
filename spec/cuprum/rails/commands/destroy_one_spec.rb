# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/command_contracts'

require 'cuprum/rails/commands/destroy_one'
require 'cuprum/rails/rspec/command_contract'

require 'support/examples/rails_command_examples'

RSpec.describe Cuprum::Rails::Commands::DestroyOne do
  include Cuprum::Collections::RSpec::Contracts::CommandContracts
  include Spec::Support::Examples::RailsCommandExamples

  include_context 'with parameters for a Rails command'

  subject(:command) do
    described_class.new(
      record_class: record_class,
      **constructor_options
    )
  end

  let(:expected_data) { record_class.new(matching_data) }

  include_contract Cuprum::Rails::RSpec::COMMAND_CONTRACT

  include_contract 'should be a destroy one command'

  wrap_context 'with a custom primary key' do
    include_contract 'should be a destroy one command'
  end
end
