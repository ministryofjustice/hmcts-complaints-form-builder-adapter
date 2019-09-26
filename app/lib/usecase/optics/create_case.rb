module Usecase
  module Optics
    class CreateCase
      def initialize(optics_gateway:, presenter:, get_bearer_token:)
        @optics_gateway = optics_gateway
        @presenter = presenter
        @get_bearer_token = get_bearer_token
      end

      def execute
        Rails.logger.debug("Optics CreateCase payload: #{@presenter.optics_payload.to_json}")

        @optics_gateway.post(
          body: @presenter.optics_payload.to_json,
          bearer_token: @get_bearer_token.execute
        )
      end
    end
  end
end
