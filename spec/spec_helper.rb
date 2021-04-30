# frozen_string_literal: true

unless ENV['COVERAGE'] == 'false'
  require 'simplecov'

  SimpleCov.start
end

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../config/application', __dir__)

Rails.application.initialize!

require 'rspec/sleeping_king_studios/all'
require 'byebug'
require 'database_cleaner/active_record'

require 'cuprum/rspec/be_a_result'
require 'stannum/rspec/validate_parameter'

Stannum::RSpec::ValidateParameterMatcher.add_parameter_mapping(
  match: lambda do |actual:, method_name:, **_|
    actual.is_a?(Cuprum::Command) && method_name == :call
  end,
  map:   lambda do |actual:, **_|
    actual.method(:process).parameters
  end
)

# Isolated namespace for defining spec-only or transient objects.
module Spec; end

require 'support/contract_helpers'

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  include Stannum::RSpec::Matchers

  config.extend  RSpec::SleepingKingStudios::Concerns::ExampleConstants
  config.extend  RSpec::SleepingKingStudios::Concerns::FocusExamples
  config.extend  RSpec::SleepingKingStudios::Concerns::WrapExamples
  config.include RSpec::SleepingKingStudios::Examples::PropertyExamples
  config.extend  Spec::ContractHelpers

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:example) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.disable_monkey_patching!

  # This allows you to limit a spec run to individual examples or groups
  # you care about by tagging them with `:focus` metadata.
  config.filter_run_when_matching :focus

  # Allows RSpec to persist some state between runs.
  config.example_status_persistence_file_path = 'spec/examples.txt'

  # Print the 10 slowest examples and example groups.
  config.profile_examples = 10 if ENV['CI']

  # Run specs in random order to surface order dependencies.
  config.order = :random
  Kernel.srand config.seed

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # Enable only the newer, non-monkey-patching expect syntax.
    expectations.syntax = :expect

    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Enable only the newer, non-monkey-patching expect syntax.
    mocks.syntax = :expect

    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended.
    mocks.verify_partial_doubles = true
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
  # have no way to turn it off -- the option exists only for backwards
  # compatibility in RSpec 3). It causes shared context metadata to be
  # inherited by the metadata hash of host groups and examples, rather than
  # triggering implicit auto-inclusion in groups with matching metadata.
  config.shared_context_metadata_behavior = :apply_to_host_groups
end
