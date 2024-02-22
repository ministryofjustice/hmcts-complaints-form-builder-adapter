module Presenter
  class Comment < BasePresenter
    REQUEST_METHOD = 'Online form'.freeze

    def optics_payload
      {
        Type: type,
        RequestDate: request_date,
        RequestMethod: REQUEST_METHOD,
        AssignedTeam: submission_answers.fetch(:'which-contact-with_autocomplete_1', ''),
        'Case.ServiceTeam': submission_answers.fetch(:'which-contact-with_autocomplete_1', ''),
        Details: submission_answers.fetch(:feedback_textarea_1, '')
      }
    end

    private

    def type
      ENV['COMMENT_TYPE'] || ''
    end
  end
end
