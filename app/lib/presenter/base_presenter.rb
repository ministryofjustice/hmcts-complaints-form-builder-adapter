module Presenter
  class BasePresenter
    def initialize(form_builder_payload:)
      @form_builder_payload = form_builder_payload
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

    def format_date_optics(date)
      Date.parse(date).to_s
    end

    def format_phone_number_optics(phone_string)
      phone_string.to_i
    end
  end
end
