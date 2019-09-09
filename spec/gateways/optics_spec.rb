describe OpticsGateway do
  context 'when the request is empty but for authentication' do
    let(:endpoint) { 'https://uat.icasework.com/createcase' }
    let(:date) { Time.now.iso8601.split('T')[0] }
    let(:secret_key) { Rails.application.config.auth.fetch(:optics_secret_key) }
    let(:signature) { Digest::MD5.hexdigest("#{date}#{secret_key}") }
    let(:api_key) { Rails.application.config.auth.fetch(:optics_api_key) }
    let(:payload) do
      {
        db: 'hmcts',
        Type: 'Complaint',
        Signature: signature,
        Key: api_key,
        Format: 'json',
        RequestDate: Date.today,
        Team: 'INBOX',
        Customer: {}
      }
    end
    let(:expected_query) do
      payload.map { |k, v| v.is_a?(Hash) ? (v.map { |a, b| "#{k}.#{a}=#{URI.encode_www_form(b)}" }) : "#{k}=#{v}" }.join('&')
    end

    before do
      stub_request(:post, "#{endpoint}?#{expected_query}")
        .to_return(status: 200, body: '', headers: {})
    end

    it 'creates a payload with a signature and a key' do
      gateway = OpticsGateway.new
      response = gateway.create_complaint
      expect(response.code).to eq(200)
    end
  end
end
