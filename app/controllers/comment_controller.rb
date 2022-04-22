class CommentController < ApplicationController
  def create
    SendCommentJob.perform_later(form_builder_payload: @decrypted_body)

    render json: { placeholder: true }, status: 201
  end
end
