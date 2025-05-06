# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'cuprum',
  '>= 1.3.0.alpha',
  git:    'https://github.com/sleepingkingstudios/cuprum.git',
  branch: 'main'
gem 'cuprum-collections',
  '>= 0.5.0.alpha',
  git:    'https://github.com/sleepingkingstudios/cuprum-collections',
  branch: 'main'
gem 'rails', '~> 8.0.0'
gem 'sleeping_king_studios-tasks', '~> 0.4', '>= 0.4.1'
gem 'sleeping_king_studios-tools',
  '>= 1.2.0.alpha',
  git:    'https://github.com/sleepingkingstudios/sleeping_king_studios-tools.git',
  branch: 'main'
gem 'stannum',
  '>= 0.4.0.alpha',
  git:    'https://github.com/sleepingkingstudios/stannum.git',
  branch: 'main'

group :development, :test do
  gem 'appraisal', '~> 2.4'
  gem 'byebug', '~> 11.0'
  gem 'database_cleaner-active_record', '~> 2.2'
  gem 'pg', '~> 1.5'
end

group :doc do
  gem 'commonmarker', '~> 0.23', require: false
  gem 'yard',         '~> 0.9',  require: false
end

group :test do
  gem 'rspec', '~> 3.13'
  gem 'rspec-sleeping_king_studios', '~> 2.8', '>= 2.8.1'
  gem 'rubocop', '~> 1.74'
  gem 'rubocop-factory_bot', '~> 2.27'
  gem 'rubocop-rails', '~> 2.30'
  gem 'rubocop-rake', '~> 0.7'
  gem 'rubocop-rspec', '~> 3.5'
  gem 'rubocop-rspec_rails', '~> 2.31'
  gem 'simplecov', '~> 0.22'
end
