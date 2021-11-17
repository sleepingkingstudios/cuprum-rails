# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

group :development, :test do
  gem 'byebug', '~> 11.0'
end

gem 'cuprum-collections',
  branch: 'main',
  git:    'https://github.com/sleepingkingstudios/cuprum-collections'

gem 'sleeping_king_studios-tasks', '~> 0.4', '>= 0.4.1'

group :rails do
  gem 'database_cleaner-active_record'
  gem 'pg'
  gem 'rails', '~> 6.0'
  gem 'rake'
end
