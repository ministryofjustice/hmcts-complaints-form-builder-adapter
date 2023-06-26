class FeedbackController < ApplicationController
  def create
    SendFeedbackJob.perform_later(form_builder_payload: @decrypted_body, api_version: @api_version)

    render json: { placeholder: true }, status: 201
  end
end
