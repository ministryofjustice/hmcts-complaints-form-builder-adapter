source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').strip

gem 'delayed_job_active_record', '~> 4.1'
gem 'httparty', '~> 0.17.0'
gem 'jwe', '~> 0.4.0'
gem 'jwt', '~> 2.2'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.1'
gem 'rails', '~> 6.0.0'
gem 'sentry-raven', '~> 2.11'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rubocop', '~> 0.74.0'
  gem 'rubocop-rspec', '~> 1.35'
end

group :test do
  gem 'rspec-rails'
  gem 'timecop', '~> 0.9.1'
  gem 'webmock', '~> 3.7.3'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
