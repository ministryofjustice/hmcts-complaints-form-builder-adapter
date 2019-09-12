describe Gateway::Optics do
  subject(:gateway) { described_class.new(secret_key: secret_key, api_key: api_key) }

  let(:api_key) { 'foo' }
  let(:secret_key) { 'bar' }
  let(:jwt_token) { 'eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJmb28iLCJhdWQiOiJodHRwczovL3VhdC5pY2FzZXdvcmsuY29tL3Rva2VuIiwiaWF0IjoxNTY4MjE2MDg2LCJleHAiOjE1ODExNzYwODZ9.0VbK6jGM3Ux8sHq3ekkz-g5xkLxFY4c_6CRVEkA1Sh4' }

  let(:bearer_token) { SecureRandom.alphanumeric(20) }

  describe '#generate_jwt' do
    before do
      Timecop.freeze(Time.parse('2019-09-11 15:34:46 +0000'))
    end

    after do
      Timecop.return
    end

    let(:expected_payload) do
      [
        { 'aud' => 'https://uat.icasework.com/token',
          'exp' => 1_581_176_086,
          'iat' => 1_568_216_086,
          'iss' => 'foo' },
        { 'alg' => 'HS256' }
      ]
    end

    it 'returns the expected jwt token' do
      expect(gateway.generate_jwt).to eq(jwt_token)
    end

    it 'can be decripted' do
      decoded_token = JWT.decode gateway.generate_jwt, secret_key, true, algorithm: 'HS256'
      expect(decoded_token).to eq(expected_payload)
    end
  end

  describe '#request_bearer_token' do
    before do
      stub_request(:post, 'https://uat.icasework.com/token?db=hmcts').to_return(status: 200, body: { access_token: bearer_token }.to_json)
    end

    let(:expected_body) do
      URI.encode_www_form(
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion: jwt_token
      )
    end

    it 'sends a request for a token' do
      gateway.request_bearer_token(jwt_token)
      expect(WebMock) .to have_requested(:post, 'https://uat.icasework.com/token?db=hmcts').with(
        headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
        body: expected_body
      ).once
    end

    it 'returns a new token' do
      expect(gateway.request_bearer_token(jwt_token)).to eq(bearer_token)
    end

    context 'when there is a failing status code returned' do
      before do
        stub_request(:post, 'https://uat.icasework.com/token?db=hmcts').to_return(status: 401, body: '<error>errors are returned in xml</error>')
      end

      it 'checks the return code of the request' do
        expect do
          gateway.request_bearer_token('foo')
        end.to raise_error(Gateway::Optics::ClientError)
      end
    end
  end
end
