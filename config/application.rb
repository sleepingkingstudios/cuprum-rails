# frozen_string_literal: true

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

require 'rails'
require 'active_model/railtie'
require 'active_record/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

class Application < Rails::Application
  # Initialize configuration defaults for originally generated Rails version.

  # :nocov:
  if Rails.version >= '8.0'
    config.load_defaults 8.0
  elsif Rails.version >= '7.2'
    config.load_defaults 7.2
  elsif Rails.version >= '7.1'
    config.load_defaults 7.1
  else
    config.load_defaults 7.0
  end
  # :nocov:

  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration can go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded after loading
  # the framework and any gems in your application.

  # Don't generate system test files.
  config.generators.system_tests = nil

  config.eager_load = false
end
