require 'rails_helper'

RSpec.describe Presenter::Comment do
  subject(:presenter) do
    described_class.new(form_builder_payload: base_payload)
  end

  describe '#optics_payload' do
    let(:base_payload) do
    {
      serviceSlug: 'comments-form',
      submissionId: 'df58b73f-a8c2-4c2a-90be-da67d3c24136',
      submissionAnswers:
      {
        RequestMethod: Presenter::Comment::REQUEST_METHOD,
        contact_location: '1101',
        feedback_details: 'some comment with lots of details'
      }.merge(input_payload)
    }
    end

    context 'comment type' do
      context 'when set in the environment' do
        let(:comment_type) { '1801265' }
        let(:input_payload) do
          { Type: comment_type }
        end

        before do
          allow(ENV).to receive(:[]).with('COMMENT_TYPE').and_return(comment_type)
        end

        it 'returns "1801265"' do
          expect(presenter.optics_payload[:Type]).to eq(comment_type)
        end
      end

      context 'when comment type is not set' do
        let(:comment_type) { '' }
        let(:input_payload) do
          { Type: comment_type }
        end

        before do
          allow(ENV).to receive(:[]).with('COMMENT_TYPE').and_return(comment_type)
        end

        it 'returns an empty string' do
          expect(presenter.optics_payload[:Type]).to eq(comment_type)
        end
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

    context 'request rate' do
      let(:today) { Time.now.strftime('%Y-%m-%d') }
      let(:input_payload) { {} }

      it 'returns a the date correctly formatted' do
        expect(presenter.optics_payload[:RequestDate]).to eq(today)
      end
    end

    context 'moj forms v2' do
      let(:base_payload) do
        {
          serviceSlug: 'hmcts-comments-form-eng',
          submissionId: 'df58b73f-a8c2-4c2a-90be-da67d3c24136',
          submissionAnswers:
          {
            RequestMethod: Presenter::Comment::REQUEST_METHOD,
            "which-contact-with_autocomplete_1": 'Champions',
            feedback_textarea_1: 'this is new information'
          }
        }
        end

        it 'returns the contact location' do
          expect(presenter.optics_payload[:AssignedTeam]).to eq('Champions')
        end

        it 'returns the details' do
          expect(presenter.optics_payload[:Details]).to eq('this is new information')
        end
    end
  end
end
