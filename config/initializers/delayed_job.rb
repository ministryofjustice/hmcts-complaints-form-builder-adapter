Delayed::Job.logger = Rails.logger

ActiveSupport.on_load :active_job do
  class ActiveJob::Logging::LogSubscriber
    private def args_info(job)
      ' ### args hidden ###'
    end
  end
end
