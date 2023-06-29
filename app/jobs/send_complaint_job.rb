class SendComplaintJob < ApplicationJob
  queue_as :send_complaints

  # rubocop:disable Metrics/MethodLength
  def perform(form_builder_payload:, api_version: 'v1')
    api_version = 'v1' if api_version.nil?

    Rails.logger.info("Working on job_id: #{job_id}")

    attachments = Usecase::SpawnAttachments.new(
      form_builder_payload:
    ).call
    presenter = Presenter::Complaint.new(
      form_builder_payload:,
      attachments:,
      api_version:
    )

    Usecase::Optics::CreateCase.new(
      optics_gateway: gateway,
      presenter:,
      get_bearer_token: bearer_token
    ).execute

    record_successful_submission(form_builder_payload[:submissionId])
  end
  # rubocop:enable Metrics/MethodLength
end
