require 'rails_helper'

describe Usecase::Optics::CreateCase do
  subject(:usecase) do
    described_class.new(
      optics_gateway: optics_gateway,
      presenter: presenter,
      get_bearer_token: get_bearer_token
    )
  end

  let(:get_bearer_token) do
    instance_double('Usecase::Optics::GetBearerToken')
  end
  let(:optics_gateway) { instance_spy(Gateway::Optics) }
  let(:presenter) { instance_double(Presenter::Complaint, optics_payload: {}) }

  describe '#execute' do
    before do
      allow(get_bearer_token).to receive(:execute).and_return('some token')
      usecase.execute
    end

    it 'posts to optics' do
      expect(optics_gateway).to have_received(:post).with(
        bearer_token: 'some token',
        body: {}.to_json
      ).once
    end

    it 'gets a bearer token' do
      expect(get_bearer_token).to have_received(:execute)
    end

    xit 'calls present on the presenter' do
      expect(presenter).to have_received(:present)
    end
  end
end
