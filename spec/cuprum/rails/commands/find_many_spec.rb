# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/command_contracts'

require 'cuprum/rails/commands/find_many'
require 'cuprum/rails/rspec/contracts/command_contracts'

require 'support/examples/rails_command_examples'

RSpec.describe Cuprum::Rails::Commands::FindMany do
  include Cuprum::Collections::RSpec::Contracts::CommandContracts
  include Cuprum::Rails::RSpec::Contracts::CommandContracts
  include Spec::Support::Examples::RailsCommandExamples

  include_context 'with parameters for a Rails command'

  subject(:command) do
    described_class.new(
      record_class: record_class,
      **constructor_options
    )
  end

  let(:expected_data) do
    matching_data.map do |attributes|
      attributes ? record_class.new(attributes) : nil
    end
  end

  include_contract 'should be a rails command'

  include_contract 'should be a find many command'

  wrap_context 'with a custom primary key' do
    include_contract 'should be a find many command'
  end

  describe '#call' do
    describe 'with a malformed primary key value' do
      include_context 'with a custom primary key'

      let(:primary_key_values) { %w[12345] }
      let(:expected_message) { @message } # rubocop:disable RSpec/InstanceVariable
      let(:expected_error) do
        Cuprum::Rails::Errors::InvalidStatement.new(message: expected_message)
      end

      before(:context) do # rubocop:disable RSpec/BeforeAfterAll
        value = '12345'
        query =
          Cuprum::Rails::Query.new(Tome).where { { uuid: one_of([value]) } }

        query.limit(1).to_a
      rescue ActiveRecord::StatementInvalid => exception
        @message = exception.message
      end

      it 'should return a failing result' do
        expect(command.call(primary_keys: primary_key_values))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end
  end
end
