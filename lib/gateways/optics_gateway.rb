class OpticsGateway
  CREATE_CASE_ENDPOINT = 'https://uat.icasework.com/createcase'.freeze
  SECRET_KEY = Rails.application.config.auth.fetch(:optics_secret_key)
  API_KEY = Rails.application.config.auth.fetch(:optics_api_key)

  def create_complaint
    HTTParty.post("#{CREATE_CASE_ENDPOINT}?#{query_string}")
  end

  private

  def query_string
    payload.map { |k, v| v.is_a?(Hash) ? (v.map { |a, b| "#{k}.#{a}=#{URI.encode_www_form(b)}" }) : "#{k}=#{v}" }.join('&')
  end

  def payload
    {
      db: 'hmcts',
      Type: 'Complaint',
      Signature: signature,
      Key: API_KEY,
      Format: 'json',
      RequestDate: Date.today,
      Team: 'INBOX',
      Customer: {}
     }
  end

  def signature
    date = Time.now.iso8601.split('T')[0]
    Digest::MD5.hexdigest("#{date}#{SECRET_KEY}")
  end
end
