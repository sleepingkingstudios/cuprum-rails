# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/commands/validate_one_examples'
require 'stannum/errors'

require 'cuprum/rails/records/commands/validate_one'

require 'support/examples/records/command_examples'

RSpec.describe Cuprum::Rails::Records::Commands::ValidateOne do
  include Cuprum::Collections::RSpec::Deferred::Commands::ValidateOneExamples
  include Spec::Support::Examples::Records::CommandExamples

  subject(:command) { described_class.new(collection:) }

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

  include_deferred 'with parameters for a records command'

  include_deferred 'should implement the Records::Command methods'

  include_deferred 'should implement the ValidateOne command',
    default_contract: true
end
