require 'rails_helper'

describe 'Submitting a comment', type: :request do
  include ActiveJob::TestHelper

  before do
    Timecop.freeze(Time.parse('2022-04-25 15:34:46 +0000'))

    allow(SecureRandom).to receive(:uuid).and_return(
      'e2161d54-92f8-4e10-b3a1-94630c65df3c'
    )
  end

  let(:expected_optics_payload) do
    {
      Type: '1801265',
      RequestDate: '2022-04-25',
      RequestMethod: Presenter::Comment::REQUEST_METHOD,
      AssignedTeam: '1111',
      'Case.ServiceTeam': '1111',
      Details: 'all of the feedback'
    }.to_json
  end

  after do
    Timecop.return
  end

  context 'FormBuilder v1 forms submissions' do
    before do
      allow(ENV).to receive(:[]).with('COMMENT_TYPE').and_return('1801265')

      stub_request(:post, 'https://uat.icasework.com/token?db=hmcts')
      .with(
        body: {
          'assertion' => 'eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzb21lX29wdGljc19hcGlfa2V5IiwiYXVkIjoiaHR0cHM6Ly91YXQuaWNhc2V3b3JrLmNvbS90b2tlbj9kYj1obWN0cyIsImlhdCI6MTY1MDkwMDg4Nn0.zR67gqqkz2PmgafsdBw_qFHWEDLhKsvvD9waJC3hbO8', 'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer'
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

      stub_request(:post, 'https://uat.icasework.com/createcase?db=hmcts')
        .with(
          body: expected_optics_payload,
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization'=>'Bearer some_bearer_token',
            'Content-Type'=>'application/json',
            'User-Agent'=>'Ruby'
          }
        )
        .to_return(
          {
            status: 200,
            body: 'stub case id response',
            headers: {
              'Content-Type'=>'application/x-www-form-urlencoded'
            }
          }
        )

      perform_enqueued_jobs do
        post '/v1/comment', params: encrypted_body(msg: runner_submission)
      end
    end
    let(:runner_submission) do
      {
        serviceSlug: 'comments-form',
        submissionId: '891c837c-adef-4854-8bd0-d681577f381e',
        submissionAnswers:
        {
          contact_location: '1111',
          feedback_details: 'all of the feedback'
        }
      }.to_json
    end

    include_context 'when authentication required' do
      let(:url) { '/v1/comment' }
    end

    it 'returns 201 on a valid post' do
      expect(response).to have_http_status(:created)
    end

    describe 'end to end submission' do
      it 'requests a bearer token' do
        expect(WebMock).to have_requested(:post, 'https://uat.icasework.com/token?db=hmcts').with(
          headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
          body: 'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzb21lX29wdGljc19hcGlfa2V5IiwiYXVkIjoiaHR0cHM6Ly91YXQuaWNhc2V3b3JrLmNvbS90b2tlbj9kYj1obWN0cyIsImlhdCI6MTY1MDkwMDg4Nn0.zR67gqqkz2PmgafsdBw_qFHWEDLhKsvvD9waJC3hbO8'
        ).once
      end

      it 'posts the submission to Optics' do
        expect(WebMock).to have_requested(:post, 'https://uat.icasework.com/createcase?db=hmcts').with(
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
        ).to eq('891c837c-adef-4854-8bd0-d681577f381e')
      end
    end
  end

  context 'MoJ Forms v2 submissions' do
    let(:runner_submission) do
      {
        serviceSlug: 'hmcts-comment-form-eng',
        submissionId: '72c49803-e9c3-42ac-bde1-09c04595a2d3',
        submissionAnswers:
        {
          'which-contact-with_autocomplete_1': '1111',
          feedback_textarea_1: 'all of the feedback'
        }
      }.to_json
    end

    before do
      stub_request(:post, "https://uat.icasework.com/token?db=hmcts").
      with(
        body: {"assertion"=>"eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzb21lX29wdGljc19hcGlfa2V5IiwiYXVkIjoiaHR0cHM6Ly91YXQuaWNhc2V3b3JrLmNvbS90b2tlbj9kYj1obWN0cyIsImlhdCI6MTY1MDkwMDg4Nn0.zR67gqqkz2PmgafsdBw_qFHWEDLhKsvvD9waJC3hbO8", "grant_type"=>"urn:ietf:params:oauth:grant-type:jwt-bearer"},
        headers: {
        'Accept'=>'*/*',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Content-Type'=>'application/x-www-form-urlencoded',
        'User-Agent'=>'Ruby'
        }).to_return(status: 200, body: {access_token: 'some_bearer_token'}.to_json, headers: {})

      stub_request(:post, "https://uat.icasework.com/createcase?db=hmcts").
      with(
        body: "{\"Type\":\"\",\"RequestDate\":\"2022-04-25\",\"RequestMethod\":\"Online form\",\"AssignedTeam\":\"\",\"Case.ServiceTeam\":\"\",\"Details\":\"\"}",
        headers: {
        'Accept'=>'*/*',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Authorization'=>'Bearer some_bearer_token',
        'Content-Type'=>'application/json',
        'User-Agent'=>'Ruby'
        }).to_return(status: 200, body: "", headers: {})

      perform_enqueued_jobs do
        post '/v2/comment', params: encrypted_body(msg: runner_submission)
      end
    end

    include_context 'when authentication required' do
      let(:url) { '/v2/comment' }
    end

    it 'returns 201 on a valid post' do
      expect(response).to have_http_status(:created)
    end

    describe 'end to end submission' do
      it 'requests a bearer token' do
        expect(WebMock).to have_requested(:post, 'https://uat.icasework.com/token?db=hmcts').with(
          headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
          body: 'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzb21lX29wdGljc19hcGlfa2V5IiwiYXVkIjoiaHR0cHM6Ly91YXQuaWNhc2V3b3JrLmNvbS90b2tlbj9kYj1obWN0cyIsImlhdCI6MTY1MDkwMDg4Nn0.zR67gqqkz2PmgafsdBw_qFHWEDLhKsvvD9waJC3hbO8'
        ).once
      end

      it 'posts the submission to Optics' do
        expect(WebMock).to have_requested(:post, 'https://uat.icasework.com/createcase?db=hmcts').with(
          headers: {
            'Authorization' => 'Bearer some_bearer_token',
            'Content-Type' => 'application/json'
          },
          body: '{"Type":"","RequestDate":"2022-04-25","RequestMethod":"Online form","AssignedTeam":"","Case.ServiceTeam":"","Details":""}'
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
