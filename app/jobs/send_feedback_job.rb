class SendFeedbackJob < ApplicationJob
  queue_as :send_feedback

  def perform(form_builder_payload:)
    presenter = Presenter::Feedback.new(
      form_builder_payload: form_builder_payload
    )

    Usecase::Optics::CreateCase.new(
      optics_gateway: gateway,
      presenter: presenter,
      get_bearer_token: bearer_token
    ).execute

    record_successful_submission(form_builder_payload[:submissionId])
  end
end
