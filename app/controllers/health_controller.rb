class HealthController < ActionController::API
  def show
    render plain: 'healthy'
  end

  def readiness
    # rubocop:disable Style/GuardClause
    # rubocop:disable Style/IfUnlessModifier
    if ActiveRecord::Base.connection && ActiveRecord::Base.connected?
      render plain: 'ready'
    end
    # rubocop:enable Style/GuardClause
    # rubocop:enable Style/IfUnlessModifier
  end
end
