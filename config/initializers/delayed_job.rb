# disable error logging to keep secrets out of the logs
Delayed::Backend::ActiveRecord::Job.logger.level = :fatal
Delayed::Worker.max_attempts = 5
