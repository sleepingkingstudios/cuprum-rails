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
    'bug_tracker_uri' => 'https://github.com/sleepingkingstudios/cuprum-rails/issues',
    'source_code_uri' => 'https://github.com/sleepingkingstudios/cuprum-rails'
  }

  gem.require_path = 'lib'
  gem.files        = Dir['lib/**/*.rb', 'LICENSE', '*.md']

  gem.required_ruby_version = '>= 2.6'

  gem.add_runtime_dependency 'cuprum', '>= 0.11.0', '< 2.0'
  gem.add_runtime_dependency 'cuprum-collections'
  gem.add_runtime_dependency 'stannum'

  gem.add_development_dependency 'byebug'
  gem.add_development_dependency 'rspec', '~> 3.9'
  gem.add_development_dependency 'rspec-sleeping_king_studios', '~> 2.5'
  gem.add_development_dependency 'rubocop', '~> 1.22'
  gem.add_development_dependency 'rubocop-rails', '~> 2.12'
  gem.add_development_dependency 'rubocop-rake', '~> 0.6'
  gem.add_development_dependency 'rubocop-rspec', '~> 2.5'
  gem.add_development_dependency 'simplecov', '~> 0.18'
  gem.add_development_dependency 'sleeping_king_studios-tasks', '>= 0.4.1'
  gem.add_development_dependency 'sleeping_king_studios-tools', '~> 1.0'
  gem.add_development_dependency 'thor', '~> 1.0'
end
