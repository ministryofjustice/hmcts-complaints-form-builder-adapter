require 'rails_helper'

RSpec.describe Presenter::Feedback do
  subject(:presenter) do
    described_class.new(form_builder_payload: base_payload, api_version:)
  end

  describe '#optics_payload' do
    let(:base_payload) do
    {
      serviceSlug: 'user-feedback',
      submissionId: 'd2f3829d-2496-463e-8d0a-e86e354e225a',
      submissionAnswers:
      {
        RequestMethod: Presenter::Feedback::REQUEST_METHOD,
        'External.RequestMethod': Presenter::Feedback::REQUEST_METHOD,
        contact_location: '1101',
        feedback_details: 'feedback for all'
      }.merge(input_payload)
    }
    end

    let(:api_version) { 'v1' }

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
      let(:input_payload) { { 'External.RequestMethod': '' } }

      context 'External.RequestMethod' do
        it 'should always return online form' do
          expect(presenter.optics_payload[:'External.RequestMethod']).to eq('Online form')
        end
      end

      context 'RequestMethod' do
        it 'should always return online form' do
          expect(presenter.optics_payload[:RequestMethod]).to eq('Online form')
        end
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

      context 'External.RequestDate' do
        it 'returns a the date correctly formatted' do
          expect(presenter.optics_payload[:'External.RequestDate']).to eq(today)
        end
      end

      context 'RequestDate' do
        it 'returns a the date correctly formatted' do
          expect(presenter.optics_payload[:RequestDate]).to eq(today)
        end
      end
    end

    context 'party context' do
      let(:input_payload) do
        {
          PartyContext: ''
        }
      end
      it 'should always return Main' do
        expect(presenter.optics_payload[:PartyContext]).to eq(Presenter::Feedback::PARTY_CONTEXT)
      end
    end

    context 'v2 moj-forms inputs' do
      let(:api_version) { 'v2' }
      let(:base_payload) do
        {
          serviceSlug: 'hmcts-feedback-form-eng',
          submissionId: '72c49803-e9c3-42ac-bde1-09c04595a2d3',
          submissionAnswers:
          {
            RequestMethod: Presenter::Feedback::REQUEST_METHOD,
            'External.RequestMethod': Presenter::Feedback::REQUEST_METHOD,
            whichpartofhmctswereyouincontactwith_autocomplete_1: '107',
            telluswhatwedidwell_textarea_1: 'Thank you very much'
          }
        }
      end

      it 'returns the hmcts team' do
        expect(presenter.optics_payload[:AssignedTeam]).to eq('107')
      end

      it 'returns the details of feedback' do
        expect(presenter.optics_payload[:Details]).to eq('Thank you very much')
      end
    end
  end
end
