# frozen_string_literal: true

$LOAD_PATH << './lib'

require 'cuprum/rails/version'

Gem::Specification.new do |gem|
  gem.name        = 'cuprum-rails'
  gem.version     = Cuprum::Rails::VERSION
  gem.summary     = 'An integration between Rails and the Cuprum library.'
  gem.description = <<~DESCRIPTION.gsub(/\s+/, ' ').strip
    Provides a collection adapter for ActiveRecord models, as well as command
    integrations for developing Rails controllers.
  DESCRIPTION
  gem.authors     = ['Rob "Merlin" Smith']
  gem.email       = ['merlin@sleepingkingstudios.com']
  gem.homepage    = 'http://sleepingkingstudios.com'
  gem.license     = 'MIT'

  gem.metadata = {
    'bug_tracker_uri'       => 'https://github.com/sleepingkingstudios/cuprum-rails/issues',
    'source_code_uri'       => 'https://github.com/sleepingkingstudios/cuprum-rails',
    'rubygems_mfa_required' => 'true'
  }

  gem.require_path = 'lib'
  gem.files        = Dir['lib/**/*.rb', 'LICENSE', '*.md']

  gem.required_ruby_version = '>= 2.7'

  gem.add_runtime_dependency 'cuprum', '~> 1.2'
  gem.add_runtime_dependency 'cuprum-collections', '~> 0.4'
  gem.add_runtime_dependency 'rails', '>= 6.0', '< 8'
  gem.add_runtime_dependency 'stannum', '~> 0.3'
end
