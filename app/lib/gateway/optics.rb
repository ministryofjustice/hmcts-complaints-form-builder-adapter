module Gateway
  class Optics
    class ClientError < StandardError; end

    GET_TOKEN_ENDPOINT = 'https://uat.icasework.com/token?db=hmcts'.freeze
    CREATE_CASE_ENDPOINT = 'https://uat.icasework.com/createcase?db=hmcts'.freeze

    def initialize(secret_key:, api_key:)
      @hmac_secret = secret_key
      @api_key = api_key
    end

    ONE_HOUR_IN_SECONDS = 3600 * 3600

    def generate_jwt
      payload = {
        iss: @api_key,
        aud: 'https://uat.icasework.com/token',
        iat: Time.now.to_i,
        exp: Time.now.to_i + ONE_HOUR_IN_SECONDS
      }
      JWT.encode payload, @hmac_secret, 'HS256'
    end

    def request_bearer_token(jwt_token)
      rep = post_jwt(jwt_token)
      json = JSON.parse rep.body, symbolize_names: true
      json.fetch(:access_token)
    end

    private

    def post_jwt(jwt_token)
      res = HTTParty.post(
        GET_TOKEN_ENDPOINT,
        headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
        body: URI.encode_www_form(
          grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
          assertion: jwt_token
        )
      )
      raise ClientError, res unless res.success?

      res
    end
  end
end
