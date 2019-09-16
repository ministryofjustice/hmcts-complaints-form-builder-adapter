class SendComplaintJob < ApplicationJob
  queue_as :send_complaints

  def perform(form_builder_payload:)
    Usecase::Optics::CreateCase.new(
      optics_gateway: Gateway::Optics.new,
      presenter: Presenter::Complaint.new(form_builder_payload: form_builder_payload),
      get_bearer_token: bearer_token
    ).execute
  end

  private

  def bearer_token
    Usecase::Optics::GetBearerToken.new(
      optics_gateway: Gateway::Optics.new,
      generate_jwt_token: generate_token
    )
  end

  def generate_token
    Usecase::Optics::GenerateJwtToken.new(
      url: 'https://uat.icasework.com/token?db=hmcts',
      api_key: Rails.configuration.x.optics.api_key,
      hmac_secret: Rails.configuration.x.optics.secret_key
    )
  end
end
