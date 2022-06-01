module Presenter
  class Feedback
    include SubmissionDate

    attr_reader :submission_answers

    def initialize(form_builder_payload:)
      @submission_answers = form_builder_payload.fetch(:submissionAnswers)
    end

    REQUEST_METHOD = 'Online form'.freeze
    TYPE = 'UF144908'.freeze
    PARTY_CONTEXT = 'Main'.freeze

    # rubocop:disable Metrics/MethodLength
    def optics_payload
      {
        Type: TYPE,
        RequestDate: request_date,
        RequestMethod: REQUEST_METHOD,
        'External.RequestDate': request_date,
        'External.RequestMethod': REQUEST_METHOD,
        PartyContext: PARTY_CONTEXT,
        AssignedTeam: submission_answers.fetch(:contact_location, ''),
        'Case.ServiceTeam': submission_answers.fetch(:contact_location, ''),
        Details: submission_answers.fetch(:feedback_details, '')
      }
    end
    # rubocop:enable Metrics/MethodLength
  end
end
