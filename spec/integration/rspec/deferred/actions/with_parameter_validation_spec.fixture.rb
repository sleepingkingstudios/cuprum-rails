# frozen_string_literal: true

require 'stannum/constraints/presence'
require 'stannum/contracts/hash_contract'
require 'rspec/sleeping_king_studios/concerns/example_constants'

require 'cuprum/rails'
require 'cuprum/rails/rspec/deferred/actions_examples'

RSpec.describe Cuprum::Rails::Action do
  extend  RSpec::SleepingKingStudios::Concerns::ExampleConstants
  include RSpec::SleepingKingStudios::Deferred::Consumer
  include Cuprum::Rails::RSpec::Deferred::ActionsExamples

  subject(:action) { described_class.new(command_class:) }

  let(:described_class) { Spec::ExampleAction }
  let(:command_class)   { Spec::ExampleCommand }
  let(:contract) do
    Stannum::Contracts::HashContract.new(allow_extra_keys: true) do
      key 'api_key', Stannum::Constraints::Presence.new
    end
  end

  example_class 'Spec::ExampleAction', Cuprum::Rails::Action do |klass| # rubocop:disable RSpec/DescribedClass
    klass.validate_parameters(contract)
  end

  example_class 'Spec::ExampleCommand', Cuprum::Rails::Command

  include_deferred 'should implement the action methods',
    command_class: 'Spec::ExampleCommand'

  describe '#call' do
    include_deferred 'with parameters for an action'

    include_deferred 'should validate the parameters',
      using_contract: -> { contract }

    describe 'with valid parameters' do
      let(:params) do
        { 'api_key' => '12345', 'book_id' => SecureRandom.uuid }
      end

      include_deferred 'should delegate to the command'
    end
  end
end
