# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/command_contracts'

require 'cuprum/rails/records/commands/destroy_one'
require 'cuprum/rails/rspec/contracts/command_contracts'

require 'support/examples/rails_command_examples'

RSpec.describe Cuprum::Rails::Records::Commands::DestroyOne do
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

  let(:expected_data) { record_class.new(matching_data) }

  include_contract 'should be a rails command'

  include_contract 'should be a destroy one command'

  wrap_context 'with a custom primary key' do
    include_contract 'should be a destroy one command'
  end
end
