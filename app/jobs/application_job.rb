class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  retry_on ActiveRecord::Deadlocked

  private

  def bearer_token
    Usecase::Optics::GetBearerToken.new(
      optics_gateway: gateway,
      generate_jwt_token: generate_token
    )
  end

  def generate_token
    Usecase::Optics::GenerateJwtToken.new(
      endpoint: Rails.configuration.x.optics.endpoint,
      api_key: Rails.configuration.x.optics.api_key,
      hmac_secret: Rails.configuration.x.optics.secret_key
    )
  end

  def gateway
    Gateway::Optics.new(endpoint: Rails.configuration.x.optics.endpoint)
  end

  def record_successful_submission
    ProcessedSubmission.create
  end
end
