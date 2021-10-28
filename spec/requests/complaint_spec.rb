require 'rails_helper'

describe 'Submitting a complaint', type: :request do
  include ActiveJob::TestHelper

  before do
    Timecop.freeze(Time.parse('2019-09-11 15:34:46 +0000'))

    allow(SecureRandom).to receive(:uuid).and_return('e2161d54-92f8-4e10-b3a1-94630c65df3c')

    stub_request(:post, 'https://uat.icasework.com/token?db=hmcts')
      .with(body: { 'assertion' => 'eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzb21lX29wdGljc19hcGlfa2V5IiwiYXVkIjoiaHR0cHM6Ly91YXQuaWNhc2V3b3JrLmNvbS90b2tlbj9kYj1obWN0cyIsImlhdCI6MTU2ODIxNjA4Nn0.fj8VsMONpeEmeavkh23yRsGAtfVlWkJI267gijpy6pA', 'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer' },
            headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }).to_return(status: 200, body: { access_token: 'some_bearer_token' }.to_json, headers: {})

    stub_request(:post, 'https://uat.icasework.com/createcase?db=hmcts')
      .with(
        body: expected_optics_payload,
        headers: { 'Authorization' => 'Bearer some_bearer_token', 'Content-Type' => 'application/json' }
      )
      .to_return(
        status: 200,
        body: 'stub case id response',
        headers: {}
      )
    perform_enqueued_jobs do
      post '/v1/complaint', params: encrypted_body(msg: runner_submission)
    end
  end

  let(:expected_optics_payload) do
    {
      Team: '111',
      RequestDate: Date.today.to_s,
      Details: '',
      Reference: '',
      db: 'hmcts',
      Type: 'Complaint',
      Format: 'json',
      RequestMethod: 'Online - gov.uk',
      "PartyContextManageCases": 'Main',
      'Customer.FirstName': '',
      'Customer.Surname': '',
      'Customer.Address': '',
      'Customer.Town': '',
      'Customer.County': '',
      'Customer.Postcode': '',
      'Customer.Email': '',
      'Customer.Phone': '',
      Impact: '',
      ActionRequested: '',
      'Document1.Name': 'image.png',
      'Document1.MimeType': 'image/png',
      'Document1.URL': 'https://example.com/v1/attachments/e2161d54-92f8-4e10-b3a1-94630c65df3c',
      'Document1.URLLoadContent': true
    }.to_json
  end

  let(:runner_submission) do
    {
      serviceSlug: 'claim-for-the-costs-of-a-something',
      submissionId: '891c837c-adef-4854-8bd0-d681577f381e',
      submissionAnswers:
      {
        fullname: 'Full Name',
        email: 'bob@example.com',
        is_address_uk: 'yes',
        'complaint_location': '111'
      },
      attachments: [{
        url: 'https://example.com/s3/image.png',
        encryption_key: 'secret_key',
        encryption_iv: 'secret_iv',
        filename: 'image.png',
        mimetype: 'image/png'
      }]
    }.to_json
  end

  after do
    Timecop.return
  end

  include_context 'when authentication required' do
    let(:url) { '/v1/complaint' }
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
      expect(WebMock).to have_requested(:post, 'https://uat.icasework.com/createcase?db=hmcts').with(
        headers: { 'Authorization' => 'Bearer some_bearer_token', 'Content-Type' => 'application/json' },
        body: expected_optics_payload
      ).once
    end

    it 'records that there was a successful submission' do
      expect(ProcessedSubmission.count).to eq(1)
      expect(
        ProcessedSubmission.first.submission_id
      ).to eq('891c837c-adef-4854-8bd0-d681577f381e')
    end
  end
end
