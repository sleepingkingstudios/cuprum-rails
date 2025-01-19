# frozen_string_literal: true

require 'cuprum/rails/actions/resources/update'

require 'support/examples/actions/resource_action_examples'

RSpec.describe Cuprum::Rails::Actions::Resources::Update do
  include Spec::Support::Examples::Actions::ResourceActionExamples

  subject(:action) { described_class.new(**options) }

  let(:options) { {} }

  include_deferred 'with parameters for a resource action'

  include_deferred 'should implement the resource action methods',
    command_class: Cuprum::Rails::Commands::Resources::Update

  describe '#call' do
    let(:params) do
      { 'id' => 0, resource.singular_name => resource_params }
    end
    let(:resource_params)     { { 'title' => 'Gideon the Ninth' } }
    let(:expected_parameters) { { attributes: resource_params } }
    let(:expected_value) do
      { 'book' => expected_result.value }
    end

    def call_action
      action.call(repository:, request:, resource:)
    end

    include_deferred 'should require a primary key'

    include_deferred 'should require resource params'

    describe 'with resource: a plural resource' do
      let(:resource_options)  { super().merge(plural: true) }
      let(:primary_key_value) { 0 }
      let(:expected_parameters) do
        super().merge(primary_key: primary_key_value)
      end

      describe 'with params: { id: value }' do
        let(:params) { super().merge('id' => primary_key_value) }

        include_deferred 'should wrap the command',
          command_class: Cuprum::Rails::Commands::Resources::Update
      end

      describe 'with params: { resource_id: value }' do
        let(:params) do
          super().merge("#{resource.singular_name}_id" => primary_key_value)
        end

        include_deferred 'should wrap the command',
          command_class: Cuprum::Rails::Commands::Resources::Update
      end
    end

    context 'with resource: a singular resource' do
      let(:resource_options)  { super().merge(singular: true) }

      include_deferred 'should wrap the command',
        command_class: Cuprum::Rails::Commands::Resources::Update
    end
  end
end
