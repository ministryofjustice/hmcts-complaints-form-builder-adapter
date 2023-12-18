source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').strip

gem 'daemons', '~> 1.4'
gem 'delayed_job_active_record', '~> 4.1'
gem 'httparty', '~> 0.21'
gem 'jwe', '~> 0.4.0'
gem 'jwt', '~> 2.7'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 6.4'
gem 'rails', '~> 6.1.7.1', '< 7.0.0.0'
gem 'sentry-delayed_job', '~> 5.14'
gem 'sentry-rails', '~> 5.15'
gem 'sentry-ruby', '~> 5.15'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rubocop'
  gem 'rubocop-rspec'
end

group :test do
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'simplecov'
  gem 'simplecov-console', require: false
  gem 'timecop', '~> 0.9.8'
  gem 'webmock', '~> 3.19.1'
end

group :development do
  gem 'guard-rspec', require: false
  gem 'listen', '>= 3.0.5', '< 3.9'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.1.0'
end
