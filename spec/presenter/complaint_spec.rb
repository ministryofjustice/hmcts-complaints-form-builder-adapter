describe Presenter::Complaint do
  let(:input) do
    {
      'serviceSlug': 'my-form',
      'submissionId': '1e937616-dd0b-4bc3-8c67-40e4ffd54f78',
      'submissionAnswers': {
        'first_name': 'Jim',
        'last_name': 'Complainer',
        'email_address': 'test@test.com',
        'phone': '07548733456',
        'building_street': '102 Petty France',
        'building_street_line_2': 'Westminster',
        'town_city': 'London',
        'county': 'London',
        'postcode': 'SW1H 9AJ',
        'complaint_details': 'I lost my case',
        'complaint_location': '1021',
        'submissionDate': '1568199892316'
      }
    }
  end

  let(:output) do
    {
      db: 'hmcts',
      Type: 'Complaint',
      Format: 'json',
      RequestMethod: 'Form',
      RequestDate: '1568199892316',
      Team: 'INBOX',
      "Customer.FirstName": 'Jim',
      "Customer.Surname": 'Complainer',
      "Customer.Address": '102 Petty France',
      "Customer.Town": 'London',
      "Customer.County": 'London',
      "Customer.Postcode": 'SW1H 9AJ',
      "Customer.Email": 'test@test.com',
      "Customer.Phone": '07548733456',
      Details: 'I lost my case',
      Location: '1021',
      "Case.ContactMethod": 'Online - gov.uk'
    }
  end

  it 'generates the correct hash' do
    presenter = described_class.new(form_builder_payload: input)
    expect(presenter.optics_payload).to eq(output)
  end

  context 'with missing data' do
    let(:invalid_input) do
      {
        'serviceSlug': 'my-form',
        'submissionId': '1e937616-dd0b-4bc3-8c67-40e4ffd54f78',
        'submissionAnswers': {}
      }
    end

    let(:output) do
      {
        db: 'hmcts',
        Type: 'Complaint',
        Format: 'json',
        RequestMethod: 'Form',
        RequestDate: Date.today,
        Team: 'INBOX',
        "Case.ContactMethod": 'Online - gov.uk',
        "Customer.FirstName": '',
        "Customer.Surname": '',
        "Customer.Address": '',
        "Customer.Town": '',
        "Customer.County": '',
        "Customer.Postcode": '',
        "Customer.Email": '',
        "Customer.Phone": '',
        Details: '',
        Location: ''
      }
    end

    it 'still returns a hash without failures' do
      presenter = described_class.new(form_builder_payload: invalid_input)
      expect(presenter.optics_payload).to eq(output)
    end
  end
end
