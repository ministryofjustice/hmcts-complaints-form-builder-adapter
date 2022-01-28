namespace :db do
  namespace :migrate do
    desc 'Run db:migrate but ignore ActiveRecord::ConcurrentMigrationError errors'
    task ignore_concurrent: :environment do
      # DB migrations are called as the entry command in the Dockerfile
      # Since we have multiple pods for the Adapter we only need the first migration
      # to run and any proceeding ActiveRecord::ConcurrentMigrationError
      # can rescued instead of sending a Sentry alert.

      Rake::Task['db:migrate'].invoke
    rescue ActiveRecord::ConcurrentMigrationError
      # Move along
    end
  end
end
