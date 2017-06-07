# frozen_string_literal: true

source 'https://rubygems.org'

gem 'activesupport'
gem 'contracts'
gem 'dotenv'
gem 'puma'
gem 'rack'
gem 'rake'
gem 'redis'
gem 'sidekiq'
gem 'sinatra'
gem 'unirest'

group :development, :test do
  gem 'pry'
  gem 'pry-byebug'
  gem 'webmock'
  gem 'rubocop'
end

group :test do
  gem 'fabrication'
  gem 'faker'
  gem 'fakeredis', require: 'fakeredis/rspec'
  gem 'rack-test'
  gem 'rspec'
  gem 'rspec-instafail', require: false
  gem 'timecop'
end
