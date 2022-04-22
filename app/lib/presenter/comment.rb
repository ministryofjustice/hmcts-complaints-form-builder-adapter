module Presenter
  class Comment
    include SubmissionDate

    attr_reader :submission_answers

    def initialize(form_builder_payload:)
      @submission_answers = form_builder_payload.fetch(:submissionAnswers)
    end

    REQUEST_METHOD = 'Online form'.freeze

    def optics_payload
      {
        Type: type,
        RequestDate: request_date,
        RequestMethod: REQUEST_METHOD,
        AssignedTeam: submission_answers.fetch(:contact_location, ''),
        'Case.ServiceTeam': submission_answers.fetch(:contact_location, ''),
        Details: submission_answers.fetch(:feedback_details, '')
      }
    end

    private

    def type
      ENV['COMMENT_TYPE'] || ''
    end
  end
end
