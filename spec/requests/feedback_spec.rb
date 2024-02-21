require 'rails_helper'

describe 'Submitting feedback', type: :request do
  include ActiveJob::TestHelper

  before do
    Timecop.freeze(Time.parse('2022-05-04 15:34:46 +0000'))

    allow(SecureRandom).to receive(:uuid).and_return(
      'e2161d54-92f8-4e10-b3a1-94630c65df3c'
    )
  end

  let(:expected_optics_payload) do
    {
      Type:  Presenter::Feedback::TYPE,
      RequestDate: '2022-05-04',
      RequestMethod: Presenter::Feedback::REQUEST_METHOD,
      'External.RequestDate': '2022-05-04',
      'External.RequestMethod': Presenter::Feedback::REQUEST_METHOD,
      PartyContext: Presenter::Feedback::PARTY_CONTEXT,
      AssignedTeam: '1111',
      Details: 'all of the feedback'
    }.to_json
  end

  after do
    Timecop.return
  end

  context 'with mojforms v2 services' do
    let(:runner_submission) do
      {
        serviceSlug: 'hmcts-feedback-form-eng',
        submissionId: '72c49803-e9c3-42ac-bde1-09c04595a2d3',
        submissionAnswers:
        {
          whichpartofhmctswereyouincontactwith_autocomplete_1: '1111',
          telluswhatwedidwell_textarea_1: 'all of the feedback'
        }
      }.to_json
    end

    before do
      stub_request(:post, "https://uat.icasework.com/createcase?db=hmcts").
      with(
        body: "{\"Type\":\"UF144908\",\"RequestDate\":\"2022-05-04\",\"RequestMethod\":\"Online form\",\"External.RequestDate\":\"2022-05-04\",\"External.RequestMethod\":\"Online form\",\"PartyContext\":\"Main\",\"AssignedTeam\":\"1111\",\"Details\":\"all of the feedback\"}",
        headers: {
       'Accept'=>'*/*',
       'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
       'Authorization'=>'Bearer some_bearer_token',
       'Content-Type'=>'application/json',
       'User-Agent'=>'Ruby'
        }).
      to_return(status: 200, body: "", headers: {})

      stub_request(:post, 'https://uat.icasework.com/token?db=hmcts')
      .with(
        body: {
          'assertion' => 'eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzb21lX29wdGljc19hcGlfa2V5IiwiYXVkIjoiaHR0cHM6Ly91YXQuaWNhc2V3b3JrLmNvbS90b2tlbj9kYj1obWN0cyIsImlhdCI6MTY1MTY3ODQ4Nn0.7f-8HNHcxUK5KV6K5yWUf5C7krkjNANv6it6ADa33FY', 'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer'
        },
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type'=>'application/x-www-form-urlencoded',
          'User-Agent'=>'Ruby'
          }
        ).to_return(
          status: 200,
          body: {
            access_token: 'some_bearer_token'
          }.to_json, headers: {}
        )

      perform_enqueued_jobs do
        post '/v2/feedback', params: encrypted_body(msg: runner_submission)
      end
    end

    include_context 'when authentication required' do
      let(:url) { '/v2/feedback' }
    end

    it 'returns 201 on a valid post' do
      expect(response).to have_http_status(:created)
    end

    describe 'end to end submission' do
      it 'requests a bearer token' do
        expect(WebMock).to have_requested(:post, 'https://uat.icasework.com/token?db=hmcts').with(
          headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
          body: 'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzb21lX29wdGljc19hcGlfa2V5IiwiYXVkIjoiaHR0cHM6Ly91YXQuaWNhc2V3b3JrLmNvbS90b2tlbj9kYj1obWN0cyIsImlhdCI6MTY1MTY3ODQ4Nn0.7f-8HNHcxUK5KV6K5yWUf5C7krkjNANv6it6ADa33FY'
        ).once
      end

      it 'posts the submission to Optics' do
        expect(WebMock).to have_requested(:post, 'https://uat.icasework.com/createcase?db=hmcts').with(
          headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Bearer some_bearer_token', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'},
          body: '{"Type":"UF144908","RequestDate":"2022-05-04","RequestMethod":"Online form","External.RequestDate":"2022-05-04","External.RequestMethod":"Online form","PartyContext":"Main","AssignedTeam":"1111","Details":"all of the feedback"}'
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
