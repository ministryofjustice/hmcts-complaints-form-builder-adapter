class OpticsGateway
  CREATE_CASE_ENDPOINT = 'https://uat.icasework.com/createcase'.freeze

  def create_complaint
    HTTParty.post("#{CREATE_CASE_ENDPOINT}?#{query_string}")
  end

  private

  def query_string
    payload.map { |k,v| v.is_a?(Hash) ? (v.map { |a,b| "#{k}.#{a}=#{URI.escape(b)}" }) : "#{k}=#{v}"}.join('&')
  end

  def payload
    { Signature: signature, Key: key }
  end

  def signature
    'signature'
  end

  def key
    'key'
  end
end
