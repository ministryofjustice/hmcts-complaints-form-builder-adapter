class SendComplaintJob < ApplicationJob
  queue_as :send_complaints

  # rubocop:disable Metrics/MethodLength
  def perform(form_builder_payload:)
    Rails.logger.info("Working on job_id: #{job_id}")

    attachments = Usecase::SpawnAttachments.new(
      form_builder_payload: form_builder_payload
    ).call
    presenter = Presenter::Complaint.new(
      form_builder_payload: form_builder_payload,
      attachments: attachments
    )

    Usecase::Optics::CreateCase.new(
      optics_gateway: gateway,
      presenter: presenter,
      get_bearer_token: bearer_token
    ).execute

    record_successful_submission(form_builder_payload[:submissionId])
  end
  # rubocop:enable Metrics/MethodLength
end
