# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/example_constants'

require 'cuprum/rails'
require 'cuprum/rails/rspec/deferred/actions_examples'

RSpec.describe Cuprum::Rails::Action do
  extend  RSpec::SleepingKingStudios::Concerns::ExampleConstants
  include RSpec::SleepingKingStudios::Deferred::Consumer
  include Cuprum::Rails::RSpec::Deferred::ActionsExamples

  subject(:action) { described_class.new(command_class:) }

  deferred_context 'with a command class' do
    let(:command_class) { Spec::ExampleCommand }

    example_class 'Spec::ExampleCommand', Cuprum::Rails::Command
  end

  let(:command_class) { nil }

  let(:described_class) { Spec::ExampleAction }

  example_class 'Spec::ExampleAction', Cuprum::Rails::Action # rubocop:disable RSpec/DescribedClass

  include_deferred 'should implement the action methods'

  describe '#call' do
    include_deferred 'with parameters for an action'

    include_deferred 'should require a command'

    wrap_deferred 'with a command class' do
      include_deferred 'should delegate to the command'
    end
  end

  describe '#command_class' do
    wrap_deferred 'with a command class' do
      it { expect(action.command_class).to be command_class }
    end
  end
end
