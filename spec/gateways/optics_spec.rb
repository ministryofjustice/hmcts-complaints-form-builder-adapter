describe OpticsGateway do
  context 'when the request is empty but for authentication' do
    let(:endpoint) { 'https://uat.icasework.com/createcase' }
    let(:date) { Time.now.iso8601.split('T')[0] }
    let(:secret_key) { Rails.application.config.auth.fetch(:optics_secret_key) }
    let(:signature) { Digest::MD5.hexdigest("#{date}#{secret_key}") }
    let(:api_key) { Rails.application.config.auth.fetch(:optics_api_key) }
    let(:expected_query) { "Key=#{api_key}&Signature=#{signature}" }

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
