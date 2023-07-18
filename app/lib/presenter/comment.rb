module Presenter
  class Comment < BasePresenter
    REQUEST_METHOD = 'Online form'.freeze

    # rubocop:disable Metrics/MethodLength, Naming/VariableNumber
    def optics_payload
      case @api_version
      when 'v1'
        {
          Type: type,
          RequestDate: request_date,
          RequestMethod: REQUEST_METHOD,
          AssignedTeam: submission_answers.fetch(:contact_location, ''),
          'Case.ServiceTeam': submission_answers.fetch(:contact_location, ''),
          Details: submission_answers.fetch(:feedback_details, '')
        }
      when 'v2'
        {
          Type: type,
          RequestDate: request_date,
          RequestMethod: REQUEST_METHOD,
          AssignedTeam: submission_answers.fetch(:'which-contact-with_autocomplete_1', ''),
          'Case.ServiceTeam': submission_answers.fetch(:'which-contact-with_autocomplete_1', ''),
          Details: submission_answers.fetch(:feedback_textarea_1, '')
        }
      end
    end
    # rubocop:enable Metrics/MethodLength, Naming/VariableNumber

    private

    def type
      ENV['COMMENT_TYPE'] || ''
    end
  end
end
