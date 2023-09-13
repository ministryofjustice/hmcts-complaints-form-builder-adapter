module Presenter
  class Enquiry < BasePresenter
    REQUEST_METHOD = 'Online form'.freeze
    TYPE = 'HMCTS General enquiry'.freeze

    # rubocop:disable Metrics/MethodLength, Naming/VariableNumber
    def optics_payload
      {
        Type: TYPE,
        RequestDate: request_date,
        RequestMethod: REQUEST_METHOD,
        'Customer.FirstName': submission_answers.fetch(:contactdetails_text_1, ''),
        'Customer.Surname': submission_answers.fetch(:contactdetails_text_2, ''),
        Reference: submission_answers.fetch(:'contact-details_text_1', ''),
        'Customer.Email': submission_answers.fetch(:usercontactemail_email_1, ''),
        AssignedTeam: submission_answers.fetch(:courttribunalorservice_autocomplete_1, 'MODELCT478747'),
        'Case.ServiceTeam': submission_answers.fetch(:courttribunalorservice_autocomplete_1, 'MODELCT478747'),
        Details: submission_answers.fetch(:area_textarea_1, '')
      }
    end
    # rubocop:enable  Metrics/MethodLength, Naming/VariableNumber
  end
end
