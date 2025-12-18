# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'cuprum', '~> 1.3'
gem 'cuprum-collections',
  '0.6.0.alpha',
  git: 'https://github.com/sleepingkingstudios/cuprum-collections'
gem 'rails', '~> 8.1.0'
gem 'sleeping_king_studios-tasks', '~> 0.4', '>= 0.4.1'
gem 'sleeping_king_studios-tools', '~> 1.2'
gem 'stannum', '~> 0.4'

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
  gem 'rubocop', '~> 1.82'
  gem 'rubocop-factory_bot', '~> 2.28'
  gem 'rubocop-rails', '~> 2.34'
  gem 'rubocop-rake', '~> 0.7', '>= 0.7.1'
  gem 'rubocop-rspec', '~> 3.8'
  gem 'rubocop-rspec_rails', '~> 2.32'
  gem 'simplecov', '~> 0.22'
end
