describe OpticsGateway do
  context 'when the request is empty but for authentication' do
    let(:endpoint) { 'https://uat.icasework.com/createcase' }
    let(:expected_signature) { 'Key=key&Signature=signature' }

    before do
      stub_request(:post, "#{endpoint}?#{expected_signature}")
        .to_return(status: 200, body: '', headers: {})
    end

    it 'creates a payload with a signature and a key' do
      gateway = OpticsGateway.new
      response = gateway.create_complaint
      expect(response.code).to eq(200)
    end
  end
end
