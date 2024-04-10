require 'rails_helper'

describe 'Submitting a complaint', type: :request do
  include ActiveJob::TestHelper

  before do
    Timecop.freeze(Time.parse('2019-09-11 15:34:46 +0000'))

    allow(SecureRandom).to receive(:uuid).and_return('e2161d54-92f8-4e10-b3a1-94630c65df3c')
  end

  let(:expected_optics_payload) do
    {
      Team: '111',
      AssignedTeam: '111',
      AssignedTeamSS: '111',
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
      'Customer.Email': '',
      'Customer.Phone': '',
      'Customer.Address': '',
      'Customer.Town': '',
      'Customer.County': '',
      'Customer.Postcode': '',
      Impact: '',
      ActionRequested: '',
      'Document1.Name': 'image.png',
      'Document1.MimeType': 'image/png',
      'Document1.URL': 'https://example.com/v1/attachments/e2161d54-92f8-4e10-b3a1-94630c65df3c',
      'Document1.URLLoadContent': true
    }.to_json
  end

  after do
    Timecop.return
  end

  context 'v2 mojforms submissions' do
    let(:runner_submission) do
      {
        serviceSlug: 'hmcts-complaint-form-eng',
        submissionId: '72c49803-e9c3-42ac-bde1-09c04595a2d3',
        submissionAnswers:
        {
          'yourname_text_1': 'John',
          'yourname_text_2': 'Doe',
          'casenumber_text_1': '',
          'youremailaddress_email_1': '',
          'yourcomplaint_textarea_1': '',
          'howhasthisaffectedyou_textarea_1': '',
          'whatcanwedotoputthisright_textarea_1': '',
          'courtortribunalyourcomplaintisabout_autocomplete_1': '111',
          'youraddress_address_1': {
            'address_line_one' => 'Street 123',
            'address_line_two' => 'High Tower',
            'city' => 'London',
            'county' => 'Greater London',
            'postcode' => 'SW1H 9EA',
            'country' => 'United Kingdom'
          }
        },
        attachments: [{
          url: 'https://example.com/s3/image.png',
          encryption_key: 'secret_key',
          encryption_iv: 'secret_iv',
          filename: 'image.png',
          mimetype: 'image/png'
        }]
      }
    end

    let(:payload_body) do
      "{\"Team\":\"111\",\"AssignedTeam\":\"111\",\"AssignedTeamSS\":\"111\",\"RequestDate\":\"2019-09-11\",\"Details\":\"\",\"Reference\":\"\",\"db\":\"hmcts\",\"Type\":\"Complaint\",\"Format\":\"json\",\"RequestMethod\":\"Online - gov.uk\",\"PartyContextManageCases\":\"Main\",\"Customer.FirstName\":\"John\",\"Customer.Surname\":\"Doe\",\"Customer.Email\":\"\",\"Customer.Phone\":\"\",\"Customer.Address\":\"Street 123, High Tower\",\"Customer.Town\":\"London\",\"Customer.County\":\"Greater London\",\"Customer.Postcode\":\"SW1H 9EA\",\"Impact\":\"\",\"ActionRequested\":\"\",\"Document1.Name\":\"image.png\",\"Document1.MimeType\":\"image/png\",\"Document1.URL\":\"https://example.com/v1/attachments/e2161d54-92f8-4e10-b3a1-94630c65df3c\",\"Document1.URLLoadContent\":true}"
    end

    before do
      stub_request(:post, 'https://uat.icasework.com/token?db=hmcts')
      .with(body: { 'assertion' => 'eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzb21lX29wdGljc19hcGlfa2V5IiwiYXVkIjoiaHR0cHM6Ly91YXQuaWNhc2V3b3JrLmNvbS90b2tlbj9kYj1obWN0cyIsImlhdCI6MTU2ODIxNjA4Nn0.fj8VsMONpeEmeavkh23yRsGAtfVlWkJI267gijpy6pA', 'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer' },
            headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }).to_return(status: 200, body: { access_token: 'some_bearer_token' }.to_json, headers: {})

      stub_request(:post, "https://uat.icasework.com/createcase?db=hmcts").
        with(
          body: payload_body,
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization'=>'Bearer some_bearer_token',
            'Content-Type'=>'application/json',
            'User-Agent'=>'Ruby'
          }).
        to_return(status: 200, body: "", headers: {})

      perform_enqueued_jobs do
        post '/v2/complaint', params: encrypted_body(msg: runner_submission.to_json)
      end
    end

    include_context 'when authentication required' do
      let(:url) { '/v2/complaint' }
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
          headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Bearer some_bearer_token', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'},
          body: payload_body
        ).once
      end

      it 'records that there was a successful submission' do
        expect(ProcessedSubmission.count).to eq(1)
        expect(
          ProcessedSubmission.first.submission_id
        ).to eq('72c49803-e9c3-42ac-bde1-09c04595a2d3')
      end
    end
  end
end
