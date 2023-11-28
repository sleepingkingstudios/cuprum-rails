# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/command_contracts'

require 'cuprum/rails/commands/update_one'
require 'cuprum/rails/rspec/command_contract'

require 'support/examples/rails_command_examples'

RSpec.describe Cuprum::Rails::Commands::UpdateOne do
  include Cuprum::Collections::RSpec::Contracts::CommandContracts
  include Spec::Support::Examples::RailsCommandExamples

  include_context 'with parameters for a Rails command'

  subject(:command) do
    described_class.new(
      record_class: record_class,
      **constructor_options
    )
  end

  let(:attributes) do
    {
      id:     0,
      title:  'Gideon the Ninth',
      author: 'Tamsyn Muir'
    }
  end
  let(:primary_key_value) do
    next super() if defined?(super())

    attributes.fetch(
      primary_key_name.to_s,
      attributes[primary_key_name.intern]
    )
  end
  let(:entity) do
    record_class
      .find(primary_key_value)
      .tap { |record| record.assign_attributes(attributes) }
  rescue ActiveRecord::RecordNotFound
    record_class.new(attributes)
  end
  let(:expected_data) { entity }

  include_contract Cuprum::Rails::RSpec::COMMAND_CONTRACT

  include_contract 'should be an update one command'

  wrap_context 'with a custom primary key' do
    let(:attributes) do
      super()
        .tap { |hsh| hsh.delete(:id) }
        .merge(uuid: '00000000-0000-0000-0000-000000000000')
    end

    include_contract 'should be an update one command'
  end
end
