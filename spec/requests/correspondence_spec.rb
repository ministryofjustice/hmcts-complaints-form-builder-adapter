require 'rails_helper'

describe 'Submitting a correspondence', type: :request do
  include ActiveJob::TestHelper

  let(:submission_id) { '891c837c-adef-4854-8bd0-d681577f381e' }
  let(:constant_data) do
    {
      db: Presenter::Correspondence::DB,
      Team: Presenter::Correspondence::TEAM,
      Type: Presenter::Correspondence::TYPE,
      'Case.ContactMethod': Presenter::Correspondence::CONTACT_METHOD
    }
  end
  let(:expected_representing_optics_payload) do
    {
      ApplicantType: 'C',
      CRefYesNo: 'Yes',
      CRef: 'some reference',
      CustomerPartyContext: 'Agent',
      Details: 'some message body thing',
      QueryType: 'B',
      ServiceType: 'A',
      ExternalId: submission_id,
      'CaseContactPostcode.Subject': 'W1 1CA',
      'CaseContactCustom17.Representative': 'Jedi Council',
      'CaseContactCustom18.Subject': '',
      'Case.ReceivedDate': '11/09/2019',
      'Applicant1.Forename1': 'Darth',
      'Applicant1.Name': 'Maul',
      'Applicant1.Email': '',
      'Applicant1.Phone': '',
      'Agent.Forename1': 'Qui Gon',
      'Agent.Name': 'Jinn',
      'Agent.Email': 'quigon@jedi-temple.com',
      'Agent.Phone': '5555555555',
    }.merge(constant_data).to_json
  end
  let(:representing_runner_submission) do
    {
      serviceSlug: 'money-claim-queries',
      submissionId: submission_id,
      submissionAnswers:
      {
        ClaimNumber: 'CaseReferenceYes',
        NewOrExistingClaim: 'existing-claim',
        CaseReference: 'some reference',
        ApplicantType: 'representing-claimant',
        MessageContent: 'some message body thing',
        ApplicantFirstName: 'Qui Gon',
        ApplicantLastName: 'Jinn',
        ApplicantEmail: 'quigon@jedi-temple.com',
        CompanyName: 'Jedi Council',
        QueryTypeDefendant: 'claimant-court-hearing',
        ServiceType: 'money-claim',
        ClientFirstName: 'Darth',
        ClientLastName: 'Maul',
        ClientPostcode: 'W1 1CA',
        ApplicantPhone: '5555555555'
      }
    }.to_json
  end
  let(:expected_self_representing_optics_payload) do
    {
      ApplicantType: 'A',
      CRefYesNo: 'No',
      CRef: '',
      CustomerPartyContext: 'Main',
      Details: 'some message body thing',
      QueryType: 'B',
      ServiceType: 'A',
      ExternalId: submission_id,
      'CaseContactPostcode.Subject': '',
      'CaseContactCustom17.Representative': '',
      'CaseContactCustom18.Subject': '',
      'Case.ReceivedDate': '11/09/2019',
      'Applicant1.Forename1': 'Qui Gon',
      'Applicant1.Name': 'Jinn',
      'Applicant1.Email': 'quigon@jedi-temple.com',
      'Applicant1.Phone': '5555555555',
      'Agent.Forename1': '',
      'Agent.Name': '',
      'Agent.Email': '',
      'Agent.Phone': ''
    }.merge(constant_data).to_json
  end
  let(:self_representing_runner_submission) do
    {
      serviceSlug: 'money-claim-queries',
      submissionId: submission_id,
      submissionAnswers:
      {
        NewOrExistingClaim: 'new-claim',
        ClaimNumber: 'CaseReferenceNo',
        CaseReference: '',
        ApplicantType: 'claimant',
        MessageContent: 'some message body thing',
        Applicant1FirstName: 'Qui Gon',
        Applicant1LastName: 'Jinn',
        Applicant1Email: 'quigon@jedi-temple.com',
        CompanyName: '',
        QueryTypeDefendant: 'claimant-court-hearing',
        ServiceType: 'money-claim',
        ClientFirstName: '',
        ClientLastName: '',
        ClientPostcode: '',
        Applicant1Phone: '5555555555'
      }
    }.to_json
  end

  before do
    Timecop.freeze(Time.parse('2019-09-11 15:34:46 +0000'))

    allow(SecureRandom).to receive(:uuid).and_return(
      'e2161d54-92f8-4e10-b3a1-94630c65df3c'
    )

    stub_request(:post, 'https://uat.icasework.com/token?db=hmcts')
      .with(
        body: {
          'assertion' => 'eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzb21lX29wdGljc19hcGlfa2V5IiwiYXVkIjoiaHR0cHM6Ly91YXQuaWNhc2V3b3JrLmNvbS90b2tlbj9kYj1obWN0cyIsImlhdCI6MTU2ODIxNjA4Nn0.fj8VsMONpeEmeavkh23yRsGAtfVlWkJI267gijpy6pA',
          'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer'
        },
        headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
      ).to_return(
        status: 200,
        body: {
          access_token: 'some_bearer_token'
        }.to_json, headers: {}
      )

    stub_request(:post, 'https://uat.icasework.com/createcase?db=hmcts')
      .with(
        body: expected_optics_payload,
        headers: {
          'Authorization' => 'Bearer some_bearer_token',
          'Content-Type' => 'application/json'
        }
      )
      .to_return(
        status: 200,
        body: 'stub case id response',
        headers: {}
      )
    perform_enqueued_jobs do
      post '/v1/correspondence', params: encrypted_body(msg: runner_submission)
    end
  end

  context 'representing' do
    let(:expected_optics_payload) { expected_representing_optics_payload }
    let(:runner_submission) { representing_runner_submission }

    include_context 'when authentication required' do
      let(:url) { '/v1/correspondence' }
    end

    it 'returns 201 on a valid post' do
      expect(response).to have_http_status(:created)
    end

    describe 'end to end submission' do
      it 'requests a bearer token' do
        expect(WebMock).to have_requested(:post, 'https://uat.icasework.com/token?db=hmcts').with(
          headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
          body: 'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzb21lX29wdGljc19hcGlfa2V5IiwiYXVkIjoiaHR0cHM6Ly91YXQuaWNhc2V3b3JrLmNvbS90b2tlbj9kYj1obWN0cyIsImlhdCI6MTU2ODIxNjA4Nn0.fj8VsMONpeEmeavkh23yRsGAtfVlWkJI267gijpy6pA'
        ).once
      end

      it 'posts the submission to Optics' do
        expect(
          WebMock
        ).to have_requested(:post, 'https://uat.icasework.com/createcase?db=hmcts').with(
          headers: {
            'Authorization' => 'Bearer some_bearer_token',
            'Content-Type' => 'application/json'
          },
          body: expected_optics_payload
        ).once
      end

      it 'records that there was a successful submission' do
        expect(ProcessedSubmission.count).to eq(1)
        expect(
          ProcessedSubmission.first.submission_id
        ).to eq(submission_id)
      end
    end
  end

  context 'self respresenting' do
    let(:expected_optics_payload) { expected_self_representing_optics_payload }
    let(:runner_submission) { self_representing_runner_submission }

    include_context 'when authentication required' do
      let(:url) { '/v1/correspondence' }
    end

    it 'returns 201 on a valid post' do
      expect(response).to have_http_status(:created)
    end

    describe 'end to end submission' do
      it 'requests a bearer token' do
        expect(WebMock).to have_requested(:post, 'https://uat.icasework.com/token?db=hmcts').with(
          headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
          body: 'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzb21lX29wdGljc19hcGlfa2V5IiwiYXVkIjoiaHR0cHM6Ly91YXQuaWNhc2V3b3JrLmNvbS90b2tlbj9kYj1obWN0cyIsImlhdCI6MTU2ODIxNjA4Nn0.fj8VsMONpeEmeavkh23yRsGAtfVlWkJI267gijpy6pA'
        ).once
      end

      it 'posts the submission to Optics' do
        expect(
          WebMock
        ).to have_requested(:post, 'https://uat.icasework.com/createcase?db=hmcts').with(
          headers: {
            'Authorization' => 'Bearer some_bearer_token',
            'Content-Type' => 'application/json'
          },
          body: expected_optics_payload
        ).once
      end

      it 'records that there was a successful submission' do
        expect(ProcessedSubmission.count).to eq(1)
        expect(
          ProcessedSubmission.first.submission_id
        ).to eq(submission_id)
      end
    end
  end

  after do
    Timecop.return
  end
end
