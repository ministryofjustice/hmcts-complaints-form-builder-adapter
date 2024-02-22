module Presenter
  class BasePresenter
    def initialize(form_builder_payload:, api_version: 'v2')
      @form_builder_payload = form_builder_payload
      @api_version = api_version
    end

    private

    attr_reader :form_builder_payload

    def submission_answers
      @submission_answers ||= form_builder_payload.fetch(:submissionAnswers)
    end

    def request_date(format = '%Y-%m-%d')
      time = submission_answers.fetch(:submissionDate, (Time.now.to_i * 1000).to_s)
      Time.at(time.to_s.to_i / 1000).strftime(format)
    end
  end
end
