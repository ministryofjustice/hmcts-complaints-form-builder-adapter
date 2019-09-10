class OpticsGateway
  CREATE_CASE_ENDPOINT = 'https://uat.icasework.com/createcase'.freeze

  def initialize(secret_key:, api_key:)
    @secret_key = secret_key
    @api_key = api_key
  end

  def create_complaint
    HTTParty.post(CREATE_CASE_ENDPOINT, query: payload)
  end

  private

  def payload
    {
      db: 'hmcts',
      Type: 'Complaint',
      Signature: signature,
      Key: @api_key,
      Format: 'json',
      RequestDate: Date.today,
      Team: 'INBOX',
      Customer: {}
    }
  end

  def signature
    date = Time.zone.now.strftime('%Y-%m-%d')
    Digest::MD5.hexdigest("#{date}#{@secret_key}")
  end
end
