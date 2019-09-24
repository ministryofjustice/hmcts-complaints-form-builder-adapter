module Gateway
  class Optics
    class ClientError < StandardError
      def initialize(response)
        super
        @response = response
      end

      def to_s
        "[OPTICS API error: Received #{@response&.code} response, with headers #{@response&.headers}] #{super}"
      end
    end

    def initialize(endpoint:)
      @get_token_url = "#{endpoint}/token?db=hmcts".freeze
      @post_case_url = "#{endpoint}/createcase?db=hmcts".freeze
    end

    def request_bearer_token(jwt_token:)
      rep = post_jwt(jwt_token)
      json = JSON.parse rep.body, symbolize_names: true
      json.fetch(:access_token)
    end

    def post(body:, bearer_token:)
      res = HTTParty.post(@post_case_url, headers: headers(bearer_token), body: body)
      Rails.logger.warning(res.body)
      res
    end

    private

    def headers(token)
      {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{token}"
      }
    end

    def post_jwt(jwt_token)
      result = HTTParty.post(
        @get_token_url,
        headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
        body: URI.encode_www_form(
          grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
          assertion: jwt_token
        )
      )
      return result if result.success?

      raise ClientError, result
    end
  end
end
