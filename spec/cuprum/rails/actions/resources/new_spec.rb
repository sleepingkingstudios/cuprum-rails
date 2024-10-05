# frozen_string_literal: true

require 'cuprum/rails/actions/resources/new'

require 'support/examples/actions/resource_action_examples'

RSpec.describe Cuprum::Rails::Actions::Resources::New do
  include Spec::Support::Examples::Actions::ResourceActionExamples

  subject(:action) { described_class.new(**options) }

  let(:options) { {} }

  include_deferred 'should implement the resource action methods',
    command_class: Cuprum::Rails::Commands::Resources::New

  describe '#call' do
    let(:resource_params)     { {} }
    let(:expected_parameters) { { attributes: resource_params } }
    let(:expected_value) do
      { 'book' => expected_result.value }
    end

    describe 'with params: { resource_name: an empty Hash }' do
      let(:resource_params) { {} }

      include_deferred 'should wrap the command',
        command_class: Cuprum::Rails::Commands::Resources::New
    end

    describe 'with params: { resource_name: a non-empty Hash }' do
      let(:resource_params) do
        {
          'title'  => 'Gideon the Ninth',
          'author' => 'Tamsyn Muir'
        }
      end
      let(:params) { { resource.singular_name => resource_params } }

      include_deferred 'should wrap the command',
        command_class: Cuprum::Rails::Commands::Resources::New
    end
  end
end
