# frozen_string_literal: true

require 'cuprum/rails/commands/resource_command'

require 'support/examples/commands/resources_examples'

RSpec.describe Cuprum::Rails::Commands::ResourceCommand do
  include Spec::Support::Examples::Commands::ResourcesExamples

  subject(:command) { described_class.new(repository:, resource:) }

  include_deferred 'with parameters for a resource command'

  include_deferred 'should implement the resource command methods'
end
