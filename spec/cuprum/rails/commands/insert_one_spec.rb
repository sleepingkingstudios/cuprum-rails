# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/command_contracts'

require 'cuprum/rails/commands/insert_one'
require 'cuprum/rails/rspec/command_contract'

require 'support/examples/rails_command_examples'

RSpec.describe Cuprum::Rails::Commands::InsertOne do
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
  let(:entity)        { record_class.new(attributes) }
  let(:expected_data) { record_class.new(attributes) }

  include_contract Cuprum::Rails::RSpec::COMMAND_CONTRACT

  include_contract 'should be an insert one command'

  wrap_context 'with a custom primary key' do
    let(:attributes) do
      super()
        .tap { |hsh| hsh.delete(:id) }
        .merge(uuid: '00000000-0000-0000-0000-000000000000')
    end

    include_contract 'should be an insert one command'
  end
end
