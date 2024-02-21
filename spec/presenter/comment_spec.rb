require 'rails_helper'

RSpec.describe Presenter::Comment do
  subject(:presenter) do
    described_class.new(form_builder_payload: base_payload, api_version: api_version)
  end

  describe '#optics_payload' do
    context 'moj forms v2' do
      let(:api_version) { 'v2' }
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
