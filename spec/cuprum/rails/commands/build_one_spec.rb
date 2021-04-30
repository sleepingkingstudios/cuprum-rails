# frozen_string_literal: true

require 'cuprum/collections/rspec/build_one_command_contract'

require 'cuprum/rails/commands/build_one'
require 'cuprum/rails/rspec/command_contract'

require 'support/examples/rails_command_examples'

RSpec.describe Cuprum::Rails::Commands::BuildOne do
  include Spec::Support::Examples::RailsCommandExamples

  include_context 'with parameters for a Rails command'

  subject(:command) do
    described_class.new(
      record_class: record_class,
      **constructor_options
    )
  end

  let(:expected_value)   { Book.new(expected_attributes) }
  let(:valid_attributes) { Book.attribute_names }

  include_contract Cuprum::Rails::RSpec::COMMAND_CONTRACT

  include_contract Cuprum::Collections::RSpec::BUILD_ONE_COMMAND_CONTRACT,
    allow_extra_attributes: false
end
