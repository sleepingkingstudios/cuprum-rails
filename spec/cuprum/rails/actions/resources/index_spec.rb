# frozen_string_literal: true

require 'cuprum/rails/actions/resources/index'

require 'support/examples/actions/resource_action_examples'

RSpec.describe Cuprum::Rails::Actions::Resources::Index do
  include Spec::Support::Examples::Actions::ResourceActionExamples

  subject(:action) { described_class.new(**options) }

  let(:options) { {} }

  include_deferred 'should implement the resource action methods',
    command_class: Cuprum::Rails::Commands::Resources::Index

  describe '#call' do
    let(:expected_parameters) do
      {
        limit:  nil,
        offset: nil,
        order:  nil,
        where:  nil
      }.merge(params)
    end
    let(:expected_value) do
      { 'books' => expected_result.value }
    end

    include_deferred 'should wrap the command',
      command_class: Cuprum::Rails::Commands::Resources::Index

    describe 'with limit: value' do
      let(:params) { super().merge(limit: 3) }

      include_deferred 'should wrap the command',
        command_class: Cuprum::Rails::Commands::Resources::Index
    end

    describe 'with offset: value' do
      let(:params) { super().merge(offset: 2) }

      include_deferred 'should wrap the command',
        command_class: Cuprum::Rails::Commands::Resources::Index
    end

    describe 'with order: value' do
      let(:params) { super().merge(order: { 'title' => :asc }) }

      include_deferred 'should wrap the command',
        command_class: Cuprum::Rails::Commands::Resources::Index
    end

    describe 'with where: value' do
      let(:params) { super().merge(where: { 'author' => 'Tamsyn Muir' }) }

      include_deferred 'should wrap the command',
        command_class: Cuprum::Rails::Commands::Resources::Index
    end
  end
end
