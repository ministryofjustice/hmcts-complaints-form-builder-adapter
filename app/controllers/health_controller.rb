class HealthController < ActionController::API
  def show
    render plain: 'healthy'
  end

  def readiness
    render plain: 'ready'
  end
end
