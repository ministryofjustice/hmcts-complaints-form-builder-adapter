Sentry.init do |config|
  string_mask = '********'

  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.logger = Logger.new($stdout)

  config.before_send = lambda do |event, _hint|
    if event.request && event.request.data
      filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
      event.request.data = filter.filter(event.request.data)
      event.request.data[:extra][:delayed_job] = string_mask if event.request.data.dig(:extra, :delayed_job).present?
      event.request.data[:extra][:active_job] = string_mask if event.request.data.dig(:extra, :active_job).present?
    end
    event
  end
end
