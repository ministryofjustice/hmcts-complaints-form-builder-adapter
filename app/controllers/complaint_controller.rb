class ComplaintController < ApplicationController
  def create
    render json: { placeholder: true }, status: 201
  end
end
