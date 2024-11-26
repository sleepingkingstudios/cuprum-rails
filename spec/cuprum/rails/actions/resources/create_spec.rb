# frozen_string_literal: true

require 'cuprum/rails/actions/resources/create'

require 'support/examples/actions/resource_action_examples'

RSpec.describe Cuprum::Rails::Actions::Resources::Create do
  include Spec::Support::Examples::Actions::ResourceActionExamples

  subject(:action) { described_class.new(**options) }

  let(:default_contract) do
    Stannum::Contracts::HashContract.new(allow_extra_keys: true) do
      key 'author', Stannum::Constraints::Presence.new
      key 'title',  Stannum::Constraints::Presence.new
    end
  end
  let(:resource_options) do
    {
      permitted_attributes: %w[title author]
    }
  end
  let(:options) { {} }

  include_deferred 'with parameters for a resource action'

  include_deferred 'should implement the resource action methods',
    command_class: Cuprum::Rails::Commands::Resources::Create

  describe '#call' do
    let(:resource_params)     { {} }
    let(:expected_parameters) { { attributes: resource_params } }
    let(:expected_value) do
      { 'book' => expected_result.value }
    end

    before(:example) do
      repository.create(
        default_contract:,
        qualified_name:   resource.qualified_name
      )
    end

    def call_action
      action.call(repository:, request:, resource:)
    end

    include_deferred 'should require resource params'

    describe 'with params: { resource_name: a valid Hash }' do
      let(:resource_params) do
        {
          'title'  => 'Gideon the Ninth',
          'author' => 'Tamsyn Muir'
        }
      end
      let(:params) { { resource.singular_name => resource_params } }

      include_deferred 'should wrap the command',
        command_class: Cuprum::Rails::Commands::Resources::Create
    end
  end
end
