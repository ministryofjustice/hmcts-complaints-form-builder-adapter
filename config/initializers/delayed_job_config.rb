Delayed::Worker.logger = ActiveSupport::Logger.new(STDOUT)
Delayed::Worker.logger.level = Logger::INFO
