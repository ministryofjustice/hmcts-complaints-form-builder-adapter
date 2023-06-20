module Presenter
  # rubocop:disable Metrics/ClassLength
  class Correspondence < BasePresenter
    AGENT = 'Agent'.freeze
    CONTACT_METHOD = 'Online form'.freeze
    DB = 'hmcts'.freeze
    EXISTING_CASE_REFERENCE = 'CaseReferenceYes'.freeze
    MAIN = 'Main'.freeze
    TEAM = '1022731A'.freeze
    TYPE = '1353909'.freeze
    APPLICANT_TYPE = {
      'claimant' => 'A',
      'defendant' => 'B',
      'representing-defendant' => 'C',
      'representing-claimant' => 'C'
    }.freeze
    QUERY_TYPE = {
      'court-judgement' => 'A',
      'defendant-court-hearing' => 'B',
      'claimant-court-hearing' => 'B',
      'progress-update' => 'C',
      'change-claim' => 'D',
      'defendant-other' => 'E',
      'claimant-other' => 'E',
      'claim-paid' => 'F',
      'claim-not-paid' => 'G'
    }.freeze

    # rubocop:disable Metrics/MethodLength
    def optics_payload
      {
        ApplicantType: applicant_type,
        CRefYesNo: case_reference_yes_no,
        CRef: case_reference,
        CustomerPartyContext: customer_party_context,
        Details: submission_answers.fetch(:MessageContent, ''),
        QueryType: QUERY_TYPE.fetch(query_type_claimant_or_defendant, ''),
        ServiceType: service_type,
        'CaseContactPostcode.Subject': submission_answers.fetch(:ClientPostcode, ''),
        'CaseContactCustom17.Representative': submission_answers.fetch(:CompanyName, ''),
        'CaseContactCustom18.Subject': '',
        'Case.ReceivedDate': request_date('%d/%m/%Y')
      }.merge(representing_data, self_representing_data, constant_data)
    end

    private

    def representing_data
      return {} if self_representing?

      {
        'Applicant1.Forename1': submission_answers.fetch(:ClientFirstName, ''),
        'Applicant1.Name': submission_answers.fetch(:ClientLastName, ''),
        'Applicant1.Email': '',
        'Applicant1.Phone': '',
        'Agent.Forename1': submission_answers.fetch(:ApplicantFirstName, ''),
        'Agent.Name': submission_answers.fetch(:ApplicantLastName, ''),
        'Agent.Email': submission_answers.fetch(:ApplicantEmail, ''),
        'Agent.Phone': submission_answers.fetch(:ApplicantPhone, '')
      }
    end

    def self_representing_data
      return {} if representing?

      {
        'Applicant1.Forename1': submission_answers.fetch(:Applicant1FirstName, ''),
        'Applicant1.Name': submission_answers.fetch(:Applicant1LastName, ''),
        'Applicant1.Email': submission_answers.fetch(:Applicant1Email, ''),
        'Applicant1.Phone': submission_answers.fetch(:Applicant1Phone, ''),
        'Agent.Forename1': '',
        'Agent.Name': '',
        'Agent.Email': '',
        'Agent.Phone': ''
      }
    end
    # rubocop:enable Metrics/MethodLength

    def applicant_type
      @applicant_type ||=
        APPLICANT_TYPE.fetch(submission_answers[:ApplicantType], '')
    end

    def case_reference_yes_no
      existing_case_reference? ? 'Yes' : 'No'
    end

    def case_reference
      existing_case_reference? ? submission_answers.fetch(:CaseReference, '') : ''
    end

    def customer_party_context
      @customer_party_context ||= applicant_type == 'C' ? AGENT : MAIN
    end

    def query_type_claimant_or_defendant
      submission_answers[:QueryTypeDefendant] ||
        submission_answers[:QueryTypeClaimant]
    end

    def service_type
      submission_answers[:ServiceType] == 'money-claim' ? 'A' : ''
    end

    def constant_data
      {
        db: DB,
        Team: TEAM,
        Type: type,
        'Case.ContactMethod': CONTACT_METHOD
      }
    end

    def type
      ENV['CORRESPONDENCE_TYPE'] || TYPE
    end

    def representing?
      customer_party_context == AGENT
    end

    def self_representing?
      customer_party_context == MAIN
    end

    def existing_case_reference?
      @existing_case_reference ||=
        submission_answers.fetch(:ClaimNumber, '') == EXISTING_CASE_REFERENCE
    end
  end
  # rubocop:enable Metrics/ClassLength
end
