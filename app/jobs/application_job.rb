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

  def previously_processed?(submission_id)
    ProcessedSubmission.exists?(submission_id: submission_id) ||
      case_exists_in_optics?(submission_id)
  end

  # rubocop:disable Metrics/MethodLength
  def case_exists_in_optics?(submission_id)
    result = gateway.get_case_attribute(submission_id, bearer_token.execute)
    if result.success?
      Rails.logger.info(
        "Case with submission ID #{submission_id} already exists in OPTICS\nRecording previously processed submission"
      )
      record_successful_submission(submission_id)
    end
    result.success?
  rescue Gateway::Optics::ClientError => e
    Raven.capture_exception(e)
    Rails.logger.warn(e.message)
    raise(e)
  end
  # rubocop:enable Metrics/MethodLength

  def gateway
    Gateway::Optics.new(endpoint: Rails.configuration.x.optics.endpoint)
  end

  def record_successful_submission(submission_id)
    ProcessedSubmission.create(submission_id:)
  end
end
