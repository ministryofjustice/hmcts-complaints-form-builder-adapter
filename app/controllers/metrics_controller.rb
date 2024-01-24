class MetricsController < ActionController::Base
  http_basic_authenticate_with(
    name: Rails.configuration.x.metrics.username,
    password: Rails.configuration.x.metrics.password
  )

  def show
    @successful_job_stats = ProcessedSubmission.count
    @pending_job_stats = Delayed::Job.where('attempts = 0').count
    @failed_job_stats = Delayed::Job.where('attempts > 0').count

    response.set_header('Content-Type', 'text/plain; version=0.0.4')
    render 'metrics/show', formats: [:text]
  end
end
