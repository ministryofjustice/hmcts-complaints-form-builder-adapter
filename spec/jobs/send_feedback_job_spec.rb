require 'rails_helper'
require_relative 'application_job_spec'

RSpec.describe SendFeedbackJob, type: :job do
  describe '#perform_later' do
    it 'queues a job' do
      expect do
        described_class.perform_later
      end.to have_enqueued_job.on_queue(
        'send_feedback'
      ).exactly(:once)
    end
  end

  describe '#perform' do
    subject(:jobs) { described_class.new }

    let(:create_token) { instance_spy(Usecase::Optics::GenerateJwtToken) }
    let(:get_bearer_token) { instance_spy(Usecase::Optics::GetBearerToken) }
    let(:create_case) { instance_spy(Usecase::Optics::CreateCase) }
    let(:presenter) { instance_spy(Presenter::Feedback) }
    let(:gateway) { instance_spy(Gateway::Optics) }
    let(:submission_id) { SecureRandom.uuid }
    let(:input) do
      {
        'submissionId': submission_id,
        'submissionAnswers': {
          contact_location: '1111',
          feedback_details: 'all of the feedback'
        }
      }
    end

    before do
      allow(Presenter::Feedback)
        .to receive(:new)
        .and_return(presenter)
        .with(form_builder_payload: input)
      allow(Usecase::Optics::GenerateJwtToken)
        .to receive(:new).and_return(create_token).with(
          endpoint: Rails.configuration.x.optics.endpoint,
          api_key: Rails.configuration.x.optics.api_key,
          hmac_secret: Rails.configuration.x.optics.secret_key
        )
      allow(Usecase::Optics::GetBearerToken)
        .to receive(:new).and_return(get_bearer_token).with(
          optics_gateway: gateway,
          generate_jwt_token: create_token
        )
      allow(Usecase::Optics::CreateCase)
        .to receive(:new).and_return(create_case).with(
          optics_gateway: gateway,
          presenter: presenter,
          get_bearer_token: get_bearer_token
        )

      allow(Gateway::Optics).to receive(:new).and_return(gateway)
    end

    context 'when the a submission was submitted to Optics' do
      before do
        allow(jobs).to receive(:previously_processed?).and_return(false)
      end

      it 'creates a new entry' do
        jobs.perform(form_builder_payload: input)
        expect(ProcessedSubmission.count).to eq(1)
      end
    end

    it_behaves_like 'an application job' do
      let(:job_type) { 'send_feedback' }
    end
  end
end
