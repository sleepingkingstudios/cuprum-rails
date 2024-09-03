# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/command_contracts'
require 'stannum/errors'

require 'cuprum/rails/commands/validate_one'
require 'cuprum/rails/rspec/contracts/command_contracts'

require 'support/examples/rails_command_examples'

RSpec.describe Cuprum::Rails::Commands::ValidateOne do
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

    Cuprum::Rails::MapErrors.instance.call(native_errors:)
  end

  include_contract 'should be a rails command'

  include_contract 'should be a validate one command',
    default_contract: true
end
