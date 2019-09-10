require 'rails_helper'

describe ApplicationController, type: :controller do
  describe '#authorize_request requires body to be json web encrypted' do
    # test controller to test ApplicationController logic
    controller(described_class) do
      def create
        render json: decrypted_body, status: :ok
      end
    end

    it 'rejects when no body' do
      post :create
      expect(response).to have_http_status(:unauthorized)
    end

    it 'rejects a unencrypted payload' do
      post :create, body: { 'something': true }.to_json
      expect(response).to have_http_status(:unauthorized)
    end

    it 'rejects a encrypted payload with a different incorrect key' do
      payload = JWE.encrypt({ msg: 'foo' }.to_json, SecureRandom.hex(8), alg: 'dir')
      post :create, body: payload
      expect(response).to have_http_status(:unauthorized)
    end

    it 'does not block a valid request' do
      post :create, body: encrypted_body
      expect(response).to have_http_status(:ok)
    end

    it 'passes decrypted payload to the controller as "decrypted_body"' do
      msg = { bar: 'foo' }.to_json
      post :create, body: encrypted_body(msg: msg)
      expect(response.body).to eq(msg)
    end
  end
end
