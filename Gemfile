# frozen_string_literal: true

source 'https://rubygems.org'

ruby(File.read(File.join(File.dirname(__FILE__), '.ruby-version')).strip)

gem 'bootsnap', require: false
gem 'devise'
gem 'pg', '~> 1.1'
gem 'puma', '>= 5.0'
gem 'rack-cors'
gem 'rails', '~> 7.2.2'
gem 'rswag'
gem 'simple_token_authentication'
gem 'tzinfo-data', platforms: %i[windows jruby]
# gem "jbuilder"
# gem "redis", ">= 4.0.1"
# gem "bcrypt", "~> 3.1.7"

group :development, :test do
  gem 'amazing_print'
  gem 'annotate'
  gem 'brakeman', require: false
  gem 'database_cleaner-active_record'
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'json_matchers'
  gem 'pry-byebug'
  gem 'rails_sql_prettifier', require: false
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'ruby-lsp'
  gem 'shoulda-matchers'
  gem 'spring'
end
