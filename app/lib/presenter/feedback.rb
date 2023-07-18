module Presenter
  class Feedback < BasePresenter
    REQUEST_METHOD = 'Online form'.freeze
    TYPE = 'UF144908'.freeze
    PARTY_CONTEXT = 'Main'.freeze

    # rubocop:disable Metrics/MethodLength
    def optics_payload
      case @api_version
      when 'v1'
        {
          Type: TYPE,
          RequestDate: request_date,
          RequestMethod: REQUEST_METHOD,
          'External.RequestDate': request_date,
          'External.RequestMethod': REQUEST_METHOD,
          PartyContext: PARTY_CONTEXT,
          AssignedTeam: submission_answers.fetch(:contact_location, ''),
          Details: submission_answers.fetch(:feedback_details, '')
        }
      when 'v2'
        {
          Type: TYPE,
          RequestDate: request_date,
          RequestMethod: REQUEST_METHOD,
          'External.RequestDate': request_date,
          'External.RequestMethod': REQUEST_METHOD,
          PartyContext: PARTY_CONTEXT,
          # rubocop:disable Naming/VariableNumber
          AssignedTeam: submission_answers.fetch(:whichpartofhmctswereyouincontactwith_autocomplete_1, ''),
          Details: submission_answers.fetch(:telluswhatwedidwell_textarea_1, '')
          # rubocop:enable Naming/VariableNumber
        }
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
