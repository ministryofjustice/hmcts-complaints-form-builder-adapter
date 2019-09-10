describe OpticsGateway do
  context 'when the request is empty but for authentication' do
    let(:endpoint) { 'https://uat.icasework.com/createcase' }
    let(:date) { Time.zone.now.strftime('%Y-%m-%d') }
    let(:secret_key) { 'secret' }
    let(:api_key) { '123' }
    let(:signature) { Digest::MD5.hexdigest("#{date}#{secret_key}") }
    let(:payload) do
      {
        db: 'hmcts',
        Type: 'Complaint',
        Signature: signature,
        Key: api_key,
        Format: 'json',
        RequestDate: date,
        Team: 'INBOX',
        Customer: {}
      }
    end
    let(:expected_query) { payload.to_query }

    before do
      stub_request(:post, "#{endpoint}?#{expected_query}")
        .to_return(status: 200, body: '', headers: {})
    end

    it 'creates a payload with a signature and a key' do
      gateway = described_class.new(secret_key: secret_key, api_key: api_key)
      response = gateway.create_complaint
      expect(response.code).to eq(200)
    end
  end
end
