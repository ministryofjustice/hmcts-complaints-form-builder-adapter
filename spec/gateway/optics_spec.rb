describe Gateway::Optics do
  subject(:gateway) { described_class.new(endpoint: endpoint) }

  let(:endpoint) { 'https://example.com' }
  let(:api_key) { 'foo' }
  let(:secret_key) { 'bar' }
  let(:token) { 'eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJmb28iLCJhdWQiOiJodHRwczovL3VhdC5pY2FzZXdvcmsuY29tL3Rva2VuIiwiaWF0IjoxNTY4MjE2MDg2LCJleHAiOjE1ODExNzYwODZ9.0VbK6jGM3Ux8sHq3ekkz-g5xkLxFY4c_6CRVEkA1Sh4' }
  let(:bearer_token) { SecureRandom.alphanumeric(20) }

  describe '#request_bearer_token' do
    before do
      stub_request(:post, "#{endpoint}/token?db=hmcts").to_return(status: 200, body: { access_token: bearer_token }.to_json)
    end

    let(:expected_body) do
      URI.encode_www_form(
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion: token
      )
    end

    it 'sends a request for a token' do
      gateway.request_bearer_token(jwt_token: token)
      expect(WebMock).to have_requested(:post, "#{endpoint}/token?db=hmcts").with(
        headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
        body: expected_body
      ).once
    end

    it 'returns a new token' do
      expect(gateway.request_bearer_token(jwt_token: token)).to eq(bearer_token)
    end

    context 'when there is a failing status code returned' do
      before do
        stub_request(:post, "#{endpoint}/token?db=hmcts").to_return(status: 401, body: '<html>errors return xml body</error>', headers: { 'error-header': 'some message' })
      end

      it 'checks the return code of the request' do
        expect do
          gateway.request_bearer_token(jwt_token: 'foo')
        end.to raise_error(Gateway::Optics::ClientError)
      end

      it 'returns the status code and headders in an error' do
        expect do
          gateway.request_bearer_token(jwt_token: 'foo')
        end.to raise_error(Gateway::Optics::ClientError)
                 .with_message(%r{\[OPTICS API error: Received 401 response, with headers {"error-header"=>\["some message"\]}\] <html>errors return xml body</error>})
      end
    end
  end

  describe '#post' do
    before do
      stub_request(:post, "#{endpoint}/createcase?db=hmcts").to_return(
        status: 200, body: {}.to_json
      )
      Timecop.freeze(Time.parse('2019-09-11 15:34:46 +0000'))
    end

    after do
      Timecop.return
    end

    let(:expected_headers) do
      {
        'Authorization' => "Bearer #{bearer_token}",
        'Content-Type' => 'application/json'
      }
    end

    it 'posts given body to optics' do
      gateway.post(body: {}, bearer_token: bearer_token)
      expect(WebMock).to have_requested(:post, "#{endpoint}/createcase?db=hmcts").with(
        headers: expected_headers,
        body: {}
      ).once
    end
  end
end
