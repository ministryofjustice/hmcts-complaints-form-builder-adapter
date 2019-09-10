class HealthController < ActionController::API
  def show
    render plain: 'healthy'
  end
end
