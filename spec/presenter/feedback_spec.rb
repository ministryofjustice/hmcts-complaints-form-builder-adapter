require 'rails_helper'

RSpec.describe Presenter::Feedback do
  subject(:presenter) do
    described_class.new(form_builder_payload: base_payload, api_version: api_version)
  end

  describe '#optics_payload' do
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
