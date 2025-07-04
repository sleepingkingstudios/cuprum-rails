# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/commands/find_one_examples'

require 'cuprum/rails/records/commands/find_one'
require 'cuprum/rails/rspec/matchers'

require 'support/examples/records/command_examples'

RSpec.describe Cuprum::Rails::Records::Commands::FindOne do
  include Cuprum::Collections::RSpec::Deferred::Commands::FindOneExamples
  include Cuprum::Rails::RSpec::Matchers
  include Spec::Support::Examples::Records::CommandExamples

  subject(:command) { described_class.new(collection:) }

  let(:expected_data) do
    next nil if matching_data.nil?

    be_a_record(record_class).with_attributes(matching_data)
  end

  include_deferred 'with parameters for a records command'

  include_deferred 'should implement the Records::Command methods'

  include_deferred 'should implement the FindOne command'

  wrap_deferred 'with a collection with a custom primary key' do
    include_deferred 'should implement the FindOne command'
  end

  describe '#call' do
    describe 'with a malformed primary key value' do
      let(:primary_key_value) { '12345' }
      let(:expected_message)  { @message } # rubocop:disable RSpec/InstanceVariable
      let(:expected_error) do
        Cuprum::Rails::Errors::InvalidStatement.new(message: expected_message)
      end

      before(:context) do # rubocop:disable RSpec/BeforeAfterAll
        value = '12345'
        query =
          Cuprum::Rails::Records::Query.new(Tome).where { { uuid: value } }

        query.limit(1).to_a
      rescue ActiveRecord::StatementInvalid => exception
        @message = exception.message
      end

      include_deferred 'with a collection with a custom primary key'

      it 'should return a failing result' do
        expect(command.call(primary_key: primary_key_value))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end
  end
end
