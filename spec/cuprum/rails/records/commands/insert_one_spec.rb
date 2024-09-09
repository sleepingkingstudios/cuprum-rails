# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/commands/insert_one_examples'

require 'cuprum/rails/records/commands/insert_one'

require 'support/examples/records/command_examples'

RSpec.describe Cuprum::Rails::Records::Commands::InsertOne do
  include Cuprum::Collections::RSpec::Deferred::Commands::InsertOneExamples
  include Spec::Support::Examples::Records::CommandExamples

  subject(:command) { described_class.new(collection:) }

  let(:attributes) do
    {
      id:     0,
      title:  'Gideon the Ninth',
      author: 'Tamsyn Muir'
    }
  end
  let(:entity)        { record_class.new(attributes) }
  let(:expected_data) { record_class.new(attributes) }

  include_deferred 'with parameters for a records command'

  include_deferred 'should implement the Records::Command methods'

  include_deferred 'should implement the InsertOne command'

  wrap_deferred 'with a collection with a custom primary key' do
    let(:attributes) do
      super()
        .tap { |hsh| hsh.delete(:id) }
        .merge(uuid: '00000000-0000-0000-0000-000000000000')
    end

    include_deferred 'should implement the InsertOne command'
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
