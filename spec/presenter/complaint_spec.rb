require 'rails_helper'

describe Presenter::Complaint do
  subject(:presenter) do
    described_class.new(form_builder_payload: input_payload,
                        attachments: attachments)
  end

  let(:input_payload) do
    {
      'serviceSlug': 'my-form',
      'submissionId': '1e937616-dd0b-4bc3-8c67-40e4ffd54f78',
      'submissionAnswers': {
        'first_name': 'Jim',
        'last_name': 'Complainer',
        'email_address': 'test@test.com',
        'phone': '07548733456',
        'building_street': '102 Petty France',
        'building_street_line2': 'Westminster',
        'town_city': 'London',
        'county': 'London',
        'postcode': 'SW1H 9AJ',
        'complaint_details': 'I lost my case',
        'impact': 'I felt sad',
        'action_requested': 'Reimbursement',
        'complaint_location': '1001',
        'submissionDate': '1568199892316',
        'case_number': '12345'
      }
    }
  end

  let(:attachments) do
    [
      Attachment.new(
        filename: 'image.png',
        mimetype: 'image/png',
        identifier: '3c535282-6ebb-41c5-807e-74394ef036b1'
      ),
      Attachment.new(
        filename: 'document.pdf',
        mimetype: 'application/pdf',
        identifier: '3c535282-6ebb-41c5-807e-74394ef036b2'
      )
    ]
  end

  let(:output) do
    {
      db: 'hmcts',
      Type: 'Complaint',
      Format: 'json',
      Team: '1001',
      AssignedTeam: '1001',
      AssignedTeamSS: '1001',
      RequestDate: '2019-09-11',
      Reference: '12345',
      "PartyContextManageCases": 'Main',
      "Customer.FirstName": 'Jim',
      "Customer.Surname": 'Complainer',
      "Customer.Address": '102 Petty France',
      "Customer.Town": 'London',
      "Customer.County": 'London',
      "Customer.Postcode": 'SW1H 9AJ',
      "Customer.Email": 'test@test.com',
      "Customer.Phone": '07548733456',
      Details: 'I lost my case',
      Impact: 'I felt sad',
      ActionRequested: 'Reimbursement',
      RequestMethod: 'Online - gov.uk',
      "Document1.Name": 'image.png',
      "Document1.URL": 'https://example.com/v1/attachments/3c535282-6ebb-41c5-807e-74394ef036b1',
      "Document1.MimeType": 'image/png',
      "Document1.URLLoadContent": true,
      "Document2.Name": 'document.pdf',
      "Document2.URL": 'https://example.com/v1/attachments/3c535282-6ebb-41c5-807e-74394ef036b2',
      "Document2.MimeType": 'application/pdf',
      "Document2.URLLoadContent": true
    }
  end

  it 'generates the correct hash' do
    expect(presenter.optics_payload).to eq(output)
  end

  context 'with missing data' do
    subject(:presenter) do
      described_class.new(form_builder_payload: invalid_input_payload,
                          attachments: [])
    end

    let(:invalid_input_payload) do
      {
        'serviceSlug': 'my-form',
        'submissionId': '1e937616-dd0b-4bc3-8c67-40e4ffd54f78',
        'submissionAnswers': {
          'complaint_location': '1001'
        }
      }
    end

    let(:output) do
      {
        db: 'hmcts',
        Type: 'Complaint',
        Format: 'json',
        Reference: '',
        RequestMethod: 'Online - gov.uk',
        "PartyContextManageCases": 'Main',
        RequestDate: Date.today.to_s,
        Team: '1001',
        AssignedTeam: '1001',
        AssignedTeamSS: '1001',
        "Customer.FirstName": '',
        "Customer.Surname": '',
        "Customer.Address": '',
        "Customer.Town": '',
        "Customer.County": '',
        "Customer.Postcode": '',
        "Customer.Email": '',
        "Customer.Phone": '',
        Details: '',
        Impact: '',
        ActionRequested: ''
      }
    end

    it 'still returns a hash without failures' do
      expect(presenter.optics_payload).to eq(output)
    end
  end
end
