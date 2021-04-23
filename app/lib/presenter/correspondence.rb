module Presenter
  class Correspondence
    attr_reader :submission_answers

    CONTACT_METHOD = 'Online form'.freeze
    DB = 'hmcts'.freeze
    TEAM = '1022731A'.freeze
    TYPE = 'Correspondence'.freeze

    def initialize(form_builder_payload:)
      @submission_answers = form_builder_payload.fetch(:submissionAnswers)
    end

    # rubocop:disable Metrics/MethodLength
    def optics_payload
      {
        ApplicantType: applicant_type,
        CRefYesNo: new_or_existing_claim,
        CRef: case_reference,
        CustomerPartyContext: customer_party_context,
        Details: submission_answers.fetch(:MessageContent, ''),
        QueryType: query_type,
        ServiceType: submission_answers.fetch(:ServiceType, ''),
        'Applicant1.Forename1': submission_answers.fetch(:ApplicantFirstName, ''),
        'Applicant1.Name': submission_answers.fetch(:ApplicantLastName, ''),
        'Applicant1.Email': submission_answers.fetch(:ContactEmail, ''),
        'Case.ReceivedDate': submission_date,
        'CaseContactCustom17.Subject': submission_answers.fetch(:CompanyName, ''),
        'CaseContactCustom18.Subject': ''
      }.merge(constant_data)
    end
    # rubocop:enable Metrics/MethodLength

    private

    def new_or_existing_claim
      @new_or_existing_claim ||= submission_answers.fetch(:NewOrExistingClaim, '')
    end

    def case_reference
      if new_or_existing_claim == 'Yes'
        submission_answers.fetch(:CaseReference, '')
      else
        ''
      end
    end

    def applicant_type
      @applicant_type ||= submission_answers.fetch(:ApplicantType, '')
    end

    def customer_party_context
      applicant_type.include?('representing') ? '' : 'Main'
    end

    def submission_date
      time = submission_answers.fetch(:submissionDate, (Time.now.to_i * 1000).to_s)
      Time.at(time.to_s.to_i / 1000).strftime('%Y-%m-%dT%H:%M:%S%z')
    end

    def query_type
      submission_answers[:QueryTypeDefendant] ||
        submission_answers.fetch(:QueryTypeClaimant, '')
    end

    def constant_data
      {
        db: DB,
        Type: TYPE,
        'Case.Team': TEAM,
        'Case.ContactMethod': CONTACT_METHOD
      }
    end
  end
end
