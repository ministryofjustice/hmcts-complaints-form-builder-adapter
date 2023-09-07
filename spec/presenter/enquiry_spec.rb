require 'rails_helper'

RSpec.describe Presenter::Enquiry do
  subject(:presenter) do
    described_class.new(form_builder_payload: base_payload)
  end

  describe '#optics_payload' do
    let(:base_payload) do
      {
        serviceSlug:"online-enquiry-form",
        submissionId:"4860481e-45ad-42ac-aaf8-c4b2c29cfa53",
        submissionAnswers:
        {
           "contactdetails_text_1":"First",
           "contactdetails_text_2":"Last",
           "case-number_radios_1":"Yes",
           "contact-details_text_1":"0000",
           "contactemail_radios_1":"Yes",
           "usercontactemail_email_1":"bestem@il",
           "area_textarea_1":"Enquiring",
           "relocation_radios_1":"Yes",
           "courttribunalorservice_autocomplete_1":"973"
          },"attachments":[]
      }
    end

    # it 'returns the case number' do
    #   expect(presenter.optics_payload[:Reference]).to eq('0000')
    # end

    it 'returns the contact location' do
      expect(presenter.optics_payload[:AssignedTeam]).to eq('973')
    end

    it 'returns the details' do
      expect(presenter.optics_payload[:Details]).to eq('Enquiring')
    end

    context 'request date' do
      let(:today) { Time.now.strftime('%Y-%m-%d') }

      context 'RequestDate' do
        it 'returns a the date correctly formatted' do
          expect(presenter.optics_payload[:RequestDate]).to eq(today)
        end
      end
    end
  end
end
