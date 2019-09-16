class SendComplaintJob < ApplicationJob
  queue_as :send_complaints

  def perform()
  end
end
