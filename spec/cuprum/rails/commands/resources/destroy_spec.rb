# frozen_string_literal: true

require 'cuprum/rails/commands/resources/destroy'
require 'cuprum/rails/rspec/deferred/commands/resources/destroy_examples'

require 'support/examples/commands/resource_command_examples'

RSpec.describe Cuprum::Rails::Commands::Resources::Destroy do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::DestroyExamples
  include Spec::Support::Examples::Commands::ResourceCommandExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:resource_options) do
    super().merge(primary_key_name: 'id')
  end

  include_deferred 'with parameters for a resource command'

  include_deferred 'should implement the resource command methods'

  include_deferred 'should implement the Destroy command'
end
