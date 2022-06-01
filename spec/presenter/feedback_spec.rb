require 'rails_helper'

RSpec.describe Presenter::Feedback do
  subject(:presenter) do
    described_class.new(form_builder_payload: base_payload)
  end

  describe '#optics_payload' do
    let(:base_payload) do
    {
      serviceSlug: 'user-feedback-form',
      submissionId: 'd2f3829d-2496-463e-8d0a-e86e354e225a',
      submissionAnswers:
      {
        RequestMethod: Presenter::Feedback::REQUEST_METHOD,
        contact_location: '1101',
        feedback_details: 'feedback for all'
      }.merge(input_payload)
    }
    end

    context 'type' do
      let(:input_payload) do
        {
          Type: ''
        }
      end

      it 'should always return the correct type' do
        expect(presenter.optics_payload[:Type]).to eq(Presenter::Feedback::TYPE)
      end
    end

    context 'request method' do
      let(:input_payload) do
        {
          RequestMethod: ''
        }
      end
      it 'should always return online form' do
        expect(presenter.optics_payload[:RequestMethod]).to eq('Online form')
      end
    end

    context 'contact location' do
      let(:input_payload) do
        {
          contact_location: '2022'
        }
      end
      it 'returns the contact location' do
        expect(presenter.optics_payload[:AssignedTeam]).to eq('2022')
      end
    end

    context 'feedback details' do
      let(:feedback) { 'all the feedback in this message body' }
      let(:input_payload) do
        {
          feedback_details: feedback
        }
      end
      it 'returns the contact location' do
        expect(presenter.optics_payload[:Details]).to eq(feedback)
      end
    end

    context 'request date' do
      let(:today) { Time.now.strftime('%Y-%m-%d') }
      let(:input_payload) { {} }

      it 'returns a the date correctly formatted' do
        expect(presenter.optics_payload[:RequestDate]).to eq(today)
      end
    end
  end
end
