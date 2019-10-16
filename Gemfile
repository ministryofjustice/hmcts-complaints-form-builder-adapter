source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').strip

gem 'daemons', '~> 1.3'
gem 'delayed_job_active_record', '~> 4.1'
gem 'httparty', '~> 0.17.1'
gem 'jwe', '~> 0.4.0'
gem 'jwt', '~> 2.2'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.2'
gem 'rails', '~> 6.0.0'
gem 'sentry-raven', '~> 2.12'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rubocop', '~> 0.75.0'
  gem 'rubocop-rspec', '~> 1.36'
end

group :test do
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'timecop', '~> 0.9.1'
  gem 'webmock', '~> 3.7.6'
end

group :development do
  gem 'guard-rspec', require: false
  gem 'listen', '>= 3.0.5', '< 3.3'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
