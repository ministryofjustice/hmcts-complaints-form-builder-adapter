module Presenter
  # rubocop:disable Metrics/ClassLength
  class Correspondence
    attr_reader :submission_answers

    AGENT = 'Agent'.freeze
    CONTACT_METHOD = 'Online form'.freeze
    DB = 'hmcts'.freeze
    EXISTING_CLAIM = 'existing-claim'.freeze
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

    def initialize(form_builder_payload:)
      @submission_answers = form_builder_payload.fetch(:submissionAnswers)
    end

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
        'Case.ReceivedDate': submission_date
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
      existing_claim? ? 'Yes' : 'No'
    end

    def case_reference
      existing_claim? ? submission_answers.fetch(:CaseReference, '') : ''
    end

    def customer_party_context
      @customer_party_context ||= applicant_type == 'C' ? AGENT : MAIN
    end

    def submission_date
      time = submission_answers.fetch(:submissionDate, (Time.now.to_i * 1000).to_s)
      Time.at(time.to_s.to_i / 1000).strftime('%d/%m/%Y')
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
        Type: TYPE,
        'Case.ContactMethod': CONTACT_METHOD
      }
    end

    def representing?
      customer_party_context == AGENT
    end

    def self_representing?
      customer_party_context == MAIN
    end

    def existing_claim?
      @existing_claim ||=
        submission_answers.fetch(:NewOrExistingClaim, '') == EXISTING_CLAIM
    end
  end
  # rubocop:enable Metrics/ClassLength
end
