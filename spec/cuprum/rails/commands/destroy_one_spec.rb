# frozen_string_literal: true

require 'cuprum/collections/rspec/destroy_one_command_contract'

require 'cuprum/rails/commands/destroy_one'
require 'cuprum/rails/rspec/command_contract'

require 'support/examples/rails_command_examples'

RSpec.describe Cuprum::Rails::Commands::DestroyOne do
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

  include_contract Cuprum::Collections::RSpec::DESTROY_ONE_COMMAND_CONTRACT

  wrap_context 'with a custom primary key' do
    include_contract Cuprum::Collections::RSpec::DESTROY_ONE_COMMAND_CONTRACT
  end
end
