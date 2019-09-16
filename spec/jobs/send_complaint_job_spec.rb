require 'rails_helper'

RSpec.describe SendComplaintJob, type: :job do
  describe '#perform_later' do
    it 'queues a job' do
      ActiveJob::Base.queue_adapter = :test
      expect do
        described_class.perform_later
      end.to have_enqueued_job.on_queue('send_complaints').exactly(:once)
    end
  end
end
