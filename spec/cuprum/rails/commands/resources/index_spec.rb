# frozen_string_literal: true

require 'cuprum/rails/commands/resources/index'
require 'cuprum/rails/rspec/deferred/commands/resources/index_examples'

require 'support/examples/commands/resource_command_examples'

RSpec.describe Cuprum::Rails::Commands::Resources::Index do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::IndexExamples
  include Spec::Support::Examples::Commands::ResourceCommandExamples

  subject(:command) { described_class.new(repository:, resource:) }

  let(:resource_options) { super().merge(default_order: 'id') }

  include_deferred 'with parameters for a resource command'

  include_deferred 'should implement the resource command methods'

  include_deferred 'should implement the Index command'
end
