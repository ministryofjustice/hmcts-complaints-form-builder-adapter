class ApplicationController < ActionController::API
  before_action :authorize_request
  attr_reader :decrypted_body

  # rubocop:disable Metrics/MethodLength
  def authorize_request
    encrypted_payload = request.raw_post
    return render_unauthorized if encrypted_payload.nil? || encrypted_payload.empty?

    begin
      @decrypted_body = JSON.parse(JWE.decrypt(encrypted_payload, jwe_key), symbolize_names: true)
    rescue JWE::DecodeError => e
      Rails.logger.info("returning unauthorized due to JWE::DecodeError '#{e}'")
      render_unauthorized
    rescue JWE::InvalidData => e
      Rails.logger.error("returning unauthorized due to JWE::InvalidData (we could be missing the decryption key) '#{e}'")
      render_unauthorized
    end
  end
  # rubocop:enable Metrics/MethodLength

  private

  def jwe_key
    Rails.configuration.shared_key
  end

  def render_unauthorized
    render status: :unauthorized
  end

  def api_version
    params[:api_version]
  end
end
