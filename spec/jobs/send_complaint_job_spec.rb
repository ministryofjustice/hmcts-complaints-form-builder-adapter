require 'rails_helper'

describe SendComplaintJob, type: :job do
  describe '#perform_later' do
    it 'queues a job' do
      expect do
        described_class.perform_later
      end.to have_enqueued_job.on_queue('send_complaints').exactly(:once)
    end
  end

  describe '#perform' do
    subject(:jobs) { described_class.new }

    let(:create_token) { instance_spy(Usecase::Optics::GenerateJwtToken) }
    let(:get_bearer_token) { instance_spy(Usecase::Optics::GetBearerToken) }
    let(:create_case) { instance_spy(Usecase::Optics::CreateCase) }
    let(:gateway) { instance_spy(Gateway::Optics) }
    let(:input) { { 'submissionAnswers': {} } }

    before do
      allow(Presenter::Complaint).to receive(:new).and_return(gateway).with(form_builder_payload: input)
      allow(Usecase::Optics::GenerateJwtToken).to receive(:new).and_return(create_token).with(
        endpoint: Rails.configuration.x.optics.endpoint,
        api_key: Rails.configuration.x.optics.api_key,
        hmac_secret: Rails.configuration.x.optics.secret_key
      )
      allow(Usecase::Optics::GetBearerToken).to receive(:new).and_return(get_bearer_token).with(
        optics_gateway: be_an_instance_of(Gateway::Optics),
        generate_jwt_token: create_token
      )
      allow(Usecase::Optics::CreateCase).to receive(:new).and_return(create_case).with(
        optics_gateway: be_an_instance_of(Gateway::Optics),
        presenter: gateway,
        get_bearer_token: get_bearer_token
      )
    end

    it 'calls the create case usecase' do
      jobs.perform(form_builder_payload: input)
      expect(create_case).to have_received(:execute)
    end
  end
end
