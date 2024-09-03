# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/command_contracts'

require 'cuprum/rails/commands/insert_one'
require 'cuprum/rails/rspec/contracts/command_contracts'

require 'support/examples/rails_command_examples'

RSpec.describe Cuprum::Rails::Commands::InsertOne do
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

  let(:attributes) do
    {
      id:     0,
      title:  'Gideon the Ninth',
      author: 'Tamsyn Muir'
    }
  end
  let(:entity)        { record_class.new(attributes) }
  let(:expected_data) { record_class.new(attributes) }

  include_contract 'should be a rails command'

  include_contract 'should be an insert one command'

  wrap_context 'with a custom primary key' do
    let(:attributes) do
      super()
        .tap { |hsh| hsh.delete(:id) }
        .merge(uuid: '00000000-0000-0000-0000-000000000000')
    end

    include_contract 'should be an insert one command'
  end

  describe '#call' do
    describe 'with attributes that violate a database constraint' do
      let(:attributes) { super().merge(title: nil) }
      let(:expected_message) do
        entity.save(validate: false)
      rescue ActiveRecord::NotNullViolation => exception
        exception.message
      end
      let(:expected_error) do
        Cuprum::Rails::Errors::InvalidStatement.new(message: expected_message)
      end

      before(:example) do
        allow(entity).to receive(:valid?).and_return(true)
      end

      it 'should return a failing result' do
        expect(command.call(entity:))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end
  end
end
