# frozen_string_literal: true

require 'cuprum/collections/rspec/fixtures'

require 'cuprum/rails/command'
require 'cuprum/rails/rspec/contracts/command_contracts'

RSpec.describe Cuprum::Rails::Command do
  include Cuprum::Rails::RSpec::Contracts::CommandContracts

  subject(:command) do
    described_class.new(
      record_class:,
      **constructor_options
    )
  end

  let(:record_class)        { Book }
  let(:constructor_options) { {} }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:collection_name, :record_class)
        .and_any_keywords
    end
  end

  include_contract 'should be a rails command'

  describe '#call' do
    it 'should define the method' do
      expect(command)
        .to respond_to(:call)
        .with_unlimited_arguments
        .and_any_keywords
    end

    it 'should return a failing result with not implemented error' do
      expect(command.call)
        .to be_a_failing_result
        .with_error(an_instance_of Cuprum::Errors::CommandNotImplemented)
    end
  end
end
