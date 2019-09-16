class SendComplaintJob < ApplicationJob
  queue_as :my_jobs

  def perform()
  end
end
