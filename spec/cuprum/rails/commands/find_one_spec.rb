# frozen_string_literal: true

require 'cuprum/collections/rspec/find_one_command_contract'

require 'cuprum/rails/commands/find_one'
require 'cuprum/rails/rspec/command_contract'

require 'support/examples/rails_command_examples'

RSpec.describe Cuprum::Rails::Commands::FindOne do
  include Spec::Support::Examples::RailsCommandExamples

  include_context 'with parameters for a Rails command'

  subject(:command) do
    described_class.new(
      record_class: record_class,
      **constructor_options
    )
  end

  let(:expected_data) do
    record_class.new(matching_data)
  end

  include_contract Cuprum::Rails::RSpec::COMMAND_CONTRACT

  include_contract Cuprum::Collections::RSpec::FIND_ONE_COMMAND_CONTRACT

  wrap_context 'with a custom primary key' do
    include_contract Cuprum::Collections::RSpec::FIND_ONE_COMMAND_CONTRACT
  end
end
