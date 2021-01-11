source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').strip

gem 'daemons', '~> 1.3'
gem 'delayed_job_active_record', '~> 4.1'
gem 'httparty', '~> 0.18.1'
gem 'jwe', '~> 0.4.0'
gem 'jwt', '~> 2.2'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 5.1'
gem 'rails', '~> 6.0.3'
gem 'sentry-raven', '3.0.4'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rubocop', '~> 1.8.1'
  gem 'rubocop-rspec', '~> 2.1'
end

group :test do
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'timecop', '~> 0.9.2'
  gem 'webmock', '~> 3.11.0'
end

group :development do
  gem 'guard-rspec', require: false
  gem 'listen', '>= 3.0.5', '< 3.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
