class CorrespondenceController < ApplicationController
  def create
    SendCorrespondenceJob.perform_later(form_builder_payload: @decrypted_body)

    render json: { placeholder: true }, status: 201
  end
end
