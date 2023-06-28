class SendCommentJob < ApplicationJob
  queue_as :send_comments

  def perform(form_builder_payload:, api_version:)
    api_version = 'v1' if api_version.nil?
    presenter = Presenter::Comment.new(form_builder_payload:, api_version:)

    Usecase::Optics::CreateCase.new(
      optics_gateway: gateway,
      presenter:,
      get_bearer_token: bearer_token
    ).execute

    record_successful_submission(form_builder_payload[:submissionId])
  end
end
