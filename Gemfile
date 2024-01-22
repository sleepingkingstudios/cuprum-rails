# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

group :development, :test do
  gem 'appraisal', '~> 2.4'
  gem 'byebug', '~> 11.0'
  gem 'database_cleaner-active_record', '~> 2.1'
  gem 'pg', '~> 1.5'
end

group :doc do
  gem 'commonmarker', '~> 0.23', require: false
  gem 'yard',         '~> 0.9',  require: false
end

group :test do
  gem 'rspec', '~> 3.12'
  gem 'rspec-sleeping_king_studios', '~> 2.7.0'
  gem 'rubocop', '~> 1.59'
  gem 'rubocop-rails', '~> 2.22', '>= 2.22.2'
  gem 'rubocop-rake', '~> 0.6'
  gem 'rubocop-rspec', '~> 2.25'
  gem 'simplecov', '~> 0.22'
end

gem 'cuprum-collections',
  git:    'https://github.com/sleepingkingstudios/cuprum-collections',
  branch: 'main'
gem 'rails', '~> 7.0'
gem 'sleeping_king_studios-tasks', '~> 0.4', '>= 0.4.1'
