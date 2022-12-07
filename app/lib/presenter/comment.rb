module Presenter
  class Comment < BasePresenter
    REQUEST_METHOD = 'Online form'.freeze

    def optics_payload
      {
        Type: type,
        RequestDate: request_date,
        RequestMethod: REQUEST_METHOD,
        AssignedTeam: submission_answers.fetch(:contact_location, ''),
        'Case.ServiceTeam': submission_answers.fetch(:contact_location, ''),
        Details: submission_answers.fetch(:feedback_details, ''),
        ExternalId: form_builder_payload.fetch(:submissionId)
      }
    end

    private

    def type
      ENV['COMMENT_TYPE'] || ''
    end
  end
end
