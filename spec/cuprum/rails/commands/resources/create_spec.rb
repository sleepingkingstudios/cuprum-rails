# frozen_string_literal: true

require 'stannum/constraints/presence'
require 'stannum/contracts/hash_contract'

require 'cuprum/rails/commands/resources/create'
require 'cuprum/rails/rspec/deferred/commands/resources/create_examples'

require 'support/examples/commands/resource_command_examples'

RSpec.describe Cuprum::Rails::Commands::Resources::Create do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::CreateExamples
  include Spec::Support::Examples::Commands::ResourceCommandExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:default_contract) do
    Stannum::Contracts::HashContract.new(allow_extra_keys: true) do
      key 'author', Stannum::Constraints::Presence.new
      key 'title',  Stannum::Constraints::Presence.new
    end
  end
  let(:permitted_attributes) do
    %w[title author series category]
  end
  let(:resource_options) { super().merge(permitted_attributes:) }

  include_deferred 'with parameters for a resource command'

  include_deferred 'should implement the resource command methods'

  include_deferred 'should implement the Create command'
end
