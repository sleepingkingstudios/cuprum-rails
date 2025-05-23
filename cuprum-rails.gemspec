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

  gem.required_ruby_version = '>= 3.1'

  gem.add_dependency 'cuprum', '~> 1.2'
  gem.add_dependency 'cuprum-collections', '~> 0.4'
  gem.add_dependency 'rails', '>= 7.0', '< 9'
  gem.add_dependency 'stannum', '~> 0.3'
end
