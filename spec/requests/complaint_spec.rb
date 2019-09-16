describe 'Submitting a complaint', type: :request do
  before do
    Timecop.freeze(Time.parse('2019-09-11 15:34:46 +0000'))
    ENV['OPTICS_API_KEY'] = 'some_optics_api_key'
    ENV['OPTICS_SECRET_KEY'] = 'some_secret_optics_api_key'

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

    post '/v1/complaint', params: encrypted_body(msg: runner_submission)
  end

  let(:expected_optics_payload) do
    {
      RequestDate: Date.today,
      Details: '',
      Location: '',
      Reference: '',
      db: 'hmcts',
      Type: 'Complaint',
      Format: 'json',
      RequestMethod: 'Form',
      Team: 'INBOX',
      'Case.ContactMethod': 'Online - gov.uk',
      'Customer.FirstName': '',
      'Customer.Surname': '',
      'Customer.Address': '',
      'Customer.Town': '',
      'Customer.County': '',
      'Customer.Postcode': '',
      'Customer.Email': '',
      'Customer.Phone': ''
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
        is_address_uk: 'yes'
      }
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
  end
end
