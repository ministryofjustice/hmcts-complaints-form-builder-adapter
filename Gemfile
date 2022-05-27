source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').strip

gem 'daemons', '~> 1.4'
gem 'delayed_job_active_record', '~> 4.1'
gem 'httparty', '~> 0.20.0'
gem 'jwe', '~> 0.4.0'
gem 'jwt', '~> 2.3'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 5.6'
gem 'rails', '~> 6.1.5.1', '< 7.0.0.0'
gem 'sentry-raven', '3.1.2'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rubocop', '~> 1.30.0'
  gem 'rubocop-rspec', '~> 2.11'
end

group :test do
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'timecop', '~> 0.9.5'
  gem 'webmock', '~> 3.14.0'
end

group :development do
  gem 'guard-rspec', require: false
  gem 'listen', '>= 3.0.5', '< 3.8'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
