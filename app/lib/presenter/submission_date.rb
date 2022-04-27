module Presenter
  module SubmissionDate
    def request_date
      time = submission_answers.fetch(:submissionDate, (Time.now.to_i * 1000).to_s)
      Time.at(time.to_s.to_i / 1000).strftime('%Y-%m-%d')
    end
  end
end
