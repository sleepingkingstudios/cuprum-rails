# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/command_contracts'

require 'cuprum/rails/commands/find_one'
require 'cuprum/rails/rspec/command_contract'

require 'support/examples/rails_command_examples'

RSpec.describe Cuprum::Rails::Commands::FindOne do
  include Cuprum::Collections::RSpec::Contracts::CommandContracts
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

  include_contract 'should be a find one command'

  wrap_context 'with a custom primary key' do
    include_contract 'should be a find one command'
  end

  describe '#call' do
    describe 'with a malformed primary key value' do
      include_context 'with a custom primary key'

      let(:primary_key_value) { '12345' }
      let(:expected_message) { @message } # rubocop:disable RSpec/InstanceVariable
      let(:expected_error) do
        Cuprum::Rails::Errors::InvalidStatement.new(message: expected_message)
      end

      before(:context) do # rubocop:disable RSpec/BeforeAfterAll
        value = '12345'
        query = Cuprum::Rails::Query.new(Tome).where { { uuid: value } }

        query.limit(1).to_a
      rescue ActiveRecord::StatementInvalid => exception
        @message = exception.message
      end

      it 'should return a failing result' do
        expect(command.call(primary_key: primary_key_value))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end
  end
end
