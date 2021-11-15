# frozen_string_literal: true

require 'cuprum/collections/rspec/validate_one_command_contract'
require 'stannum/errors'

require 'cuprum/rails/commands/validate_one'
require 'cuprum/rails/rspec/command_contract'

require 'support/examples/rails_command_examples'

RSpec.describe Cuprum::Rails::Commands::ValidateOne do
  include Spec::Support::Examples::RailsCommandExamples

  include_context 'with parameters for a Rails command'

  subject(:command) do
    described_class.new(
      record_class: record_class,
      **constructor_options
    )
  end

  let(:contract) do
    Stannum::Contract.new do
      property 'title', Stannum::Constraints::Presence.new
    end
  end
  let(:entity)             { record_class.new(attributes) }
  let(:invalid_attributes) { {} }
  let(:valid_attributes)   { { title: 'Gideon the Ninth' } }
  let(:invalid_default_attributes) do
    { title: 'Gideon the Ninth' }
  end
  let(:valid_default_attributes) do
    {
      title:  'Gideon the Ninth',
      author: 'Tamsyn Muir'
    }
  end
  let(:expected_errors) do
    native_errors = entity.tap(&:valid?).errors

    Cuprum::Rails::MapErrors.instance.call(native_errors: native_errors)
  end

  include_contract Cuprum::Rails::RSpec::COMMAND_CONTRACT

  include_contract Cuprum::Collections::RSpec::VALIDATE_ONE_COMMAND_CONTRACT,
    default_contract: true
end
