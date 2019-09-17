# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

Rails.logger = Logger.new(STDOUT)
Rails.logger.level = Logger::INFO
Rails.logger.info("Starting rails with env = #{Rails.env}")
