# frozen_string_literal: true

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

  example_class 'Spec::ExampleAction', Cuprum::Rails::Action do |klass| # rubocop:disable RSpec/DescribedClass
    klass.define_method(:build_response) do |value|
      { 'book' => value }
    end

    klass.define_method(:map_parameters) do
      request.params.fetch('book', {}).slice('title', 'author')
    end
  end

  example_class 'Spec::ExampleCommand', Cuprum::Rails::Command

  include_deferred 'should implement the action methods',
    command_class: 'Spec::ExampleCommand'

  describe '#call' do
    let(:params) do
      {
        'book' => {
          'title'  => 'Gideon the Ninth',
          'author' => 'Tamsyn Muir',
          'series' => 'The Locked Tomb'
        }
      }
    end
    let(:expected_params) do
      { title: 'Gideon the Ninth', author: 'Tamsyn Muir' }
    end
    let(:expected_result) do
      value = Struct.new(:title, :author).new(params['book'])

      Cuprum::Rails::Result.new(value:)
    end
    let(:expected_value) do
      { 'book' => expected_result.value }
    end

    include_deferred 'with parameters for an action'

    include_deferred 'should delegate to the command'
  end
end
