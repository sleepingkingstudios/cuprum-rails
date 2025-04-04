# frozen_string_literal: true

require 'cuprum/rails/rspec/deferred/commands/resources/destroy_examples'

require 'support/commands/chapters/destroy'
require 'support/examples/commands/chapters_examples'

# @note Integration test for command with custom logic.
RSpec.describe Spec::Support::Commands::Chapters::Destroy do
  include Cuprum::Rails::RSpec::Deferred::Commands::Resources::DestroyExamples
  include Spec::Support::Examples::Commands::ChaptersExamples

  subject(:command) { described_class.new(repository:, resource:) }

  def call_command
    command.call(author:, entity:, primary_key:)
  end

  include_deferred 'with parameters for a Chapter command'

  include_deferred 'with query parameters for a Chapter command'

  include_deferred 'should implement the Destroy command'
end
