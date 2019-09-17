module Usecase
  module Optics
    class GenerateJwtToken
      def initialize(endpoint:, api_key:, hmac_secret:)
        @endpoint = "#{endpoint}/token?db=hmcts"
        @api_key = api_key
        @hmac_secret = hmac_secret
      end

      def execute
        JWT.encode payload, hmac_secret, 'HS256'
      end

      private

      def payload
        {
          iss: api_key,
          aud: endpoint,
          iat: Time.now.to_i
        }
      end

      attr_reader :endpoint, :api_key, :hmac_secret
    end
  end
end
