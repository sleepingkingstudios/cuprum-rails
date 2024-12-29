# frozen_string_literal: true

require 'cuprum/rails/commands/resources/update'
require 'cuprum/rails/rspec/deferred/commands/resources/update_examples'

require 'support/examples/commands/resource_command_examples'

RSpec.describe Cuprum::Rails::Commands::Resources::Update do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::UpdateExamples
  include Spec::Support::Examples::Commands::ResourceCommandExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:default_contract) do
    Stannum::Contracts::HashContract.new(allow_extra_keys: true) do
      key 'author', Stannum::Constraints::Presence.new
      key 'title',  Stannum::Constraints::Presence.new
    end
  end
  let(:resource_options) do
    super().merge(
      permitted_attributes: %w[title author series category],
      primary_key_name:     'id'
    )
  end

  include_deferred 'with parameters for a resource command'

  include_deferred 'should implement the resource command methods'

  include_deferred 'should implement the Update command'
end
