Delayed::Job.logger = Rails.logger

# rubocop:disable Style/ClassAndModuleChildren
ActiveSupport.on_load :active_job do
  class ActiveJob::Logging::LogSubscriber
    private

    def args_info(_job)
      ' ### args hidden ###'
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
