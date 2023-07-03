class ComplaintController < ApplicationController
  def create
    SendComplaintJob.perform_later(form_builder_payload: @decrypted_body, api_version:)
    Rails.logger.warn('Created Job')
    render json: { placeholder: true }, status: 201
  end
end
