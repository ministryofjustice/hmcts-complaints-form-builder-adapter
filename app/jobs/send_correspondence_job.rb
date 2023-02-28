class SendCorrespondenceJob < ApplicationJob
  queue_as :send_correspondences

  def perform(form_builder_payload:)
    return if previously_processed?(form_builder_payload[:submissionId])
<<<<<<< HEAD

=======
>>>>>>> 644faee (Update all jobs to check for existence of previous submissions)
    presenter = Presenter::Correspondence.new(
      form_builder_payload:
    )

    Usecase::Optics::CreateCase.new(
      optics_gateway: gateway,
      presenter:,
      get_bearer_token: bearer_token
    ).execute

    record_successful_submission(form_builder_payload[:submissionId])
  end
end
