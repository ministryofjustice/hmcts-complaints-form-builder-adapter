require 'rails_helper'

RSpec.describe SendCorrespondenceJob, type: :job do
  describe '#perform_later' do
    it 'queues a job' do
      expect do
        described_class.perform_later
      end.to have_enqueued_job.on_queue(
        'send_correspondences'
      ).exactly(:once)
    end
  end

  describe '#perform' do
    subject(:jobs) { described_class.new }

    let(:create_token) { instance_spy(Usecase::Optics::GenerateJwtToken) }
    let(:get_bearer_token) { instance_spy(Usecase::Optics::GetBearerToken) }
    let(:create_case) { instance_spy(Usecase::Optics::CreateCase) }
    let(:presenter) { instance_spy(Presenter::Correspondence) }
    let(:gateway) { instance_spy(Gateway::Optics) }
    let(:input) { { 'submissionAnswers': {} } }

    before do
      allow(Presenter::Correspondence)
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
      it 'creates a new entry' do
        jobs.perform(form_builder_payload: input)
        expect(ProcessedSubmission.count).to eq(1)
      end
    end
  end
end
