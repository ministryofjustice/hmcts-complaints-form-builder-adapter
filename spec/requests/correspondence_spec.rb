require 'rails_helper'

describe 'Submitting a correspondence', type: :request do
  include ActiveJob::TestHelper

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

  let(:expected_optics_payload) do
    {
      ApplicantType: 'claimant',
      CRefYesNo: 'Yes',
      CRef: 'some reference',
      CustomerPartyContext: 'Main',
      Details: 'some message body thing',
      QueryType: 'claimant-court-hearing',
      ServiceType: 'money-claim',
      'Applicant1.Forename1': 'Qui Gon',
      'Applicant1.Name': 'Jinn',
      'Applicant1.Email': 'quigon@jedi-temple.com',
      'Case.ReceivedDate': Time.now.zone == 'BST' ? '2019-09-11T16:34:46+0100' : '2019-09-11T15:34:46+0000',
      'CaseContactCustom17.Subject': 'Jedi Council',
      'CaseContactCustom18.Subject': '',
      db: Presenter::Correspondence::DB,
      Type: Presenter::Correspondence::TYPE,
      'Case.Team': Presenter::Correspondence::TEAM,
      'Case.ContactMethod': Presenter::Correspondence::CONTACT_METHOD
    }.to_json
  end

  let(:runner_submission) do
    {
      serviceSlug: 'money-claim-queries',
      submissionId: '891c837c-adef-4854-8bd0-d681577f381e',
      submissionAnswers:
      {
        NewOrExistingClaim: 'Yes',
        CaseReference: 'some reference',
        ApplicantType: 'claimant',
        MessageContent: 'some message body thing',
        ApplicantFirstName: 'Qui Gon',
        ApplicantLastName: 'Jinn',
        ContactEmail: 'quigon@jedi-temple.com',
        CompanyName: 'Jedi Council',
        QueryTypeDefendant: 'claimant-court-hearing',
        ServiceType: 'money-claim'
      }
    }.to_json
  end

  after do
    Timecop.return
  end

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
    end
  end
end
