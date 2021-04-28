# frozen_string_literal: true

$LOAD_PATH << './lib'

require 'cuprum/rails/version'

Gem::Specification.new do |gem|
  gem.name        = 'cuprum-rails'
  gem.version     = Cuprum::Rails::VERSION
  gem.date        = Time.now.utc.strftime '%Y-%m-%d'
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
    'bug_tracker_uri' => 'https://github.com/sleepingkingstudios/cuprum-rails/issues',
    'source_code_uri' => 'https://github.com/sleepingkingstudios/cuprum-rails'
  }

  gem.require_path = 'lib'
  gem.files        = Dir['lib/**/*.rb', 'LICENSE', '*.md']

  gem.required_ruby_version = '~> 2.6'

  gem.add_runtime_dependency 'cuprum', '~> 0.10.0'
  gem.add_runtime_dependency 'cuprum-collections'
  gem.add_runtime_dependency 'stannum'

  gem.add_development_dependency 'byebug'
end
