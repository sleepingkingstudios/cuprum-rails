# frozen_string_literal: true

require 'cuprum/rails/commands/resources/show'
require 'cuprum/rails/rspec/deferred/commands/resources/show_examples'

require 'support/examples/commands/resource_command_examples'

RSpec.describe Cuprum::Rails::Commands::Resources::Show do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::ShowExamples
  include Spec::Support::Examples::Commands::ResourceCommandExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:resource_options) do
    super().merge(primary_key_name: 'id')
  end

  include_deferred 'with parameters for a resource command'

  include_deferred 'should implement the resource command methods'

  include_deferred 'should implement the Show command'
end
