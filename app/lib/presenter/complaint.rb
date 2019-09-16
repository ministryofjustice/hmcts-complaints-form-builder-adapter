module Presenter
  class Complaint
    def initialize(form_builder_payload:)
      @data = form_builder_payload.fetch(:submissionAnswers)
    end

    def optics_payload
      {
        RequestDate: @data.fetch(:submissionDate, Date.today),
        Details: @data.fetch(:complaint_details, ''),
        Location: @data.fetch(:complaint_location, '')
      }.merge(constant_data, customer_data)
    end

    private

    def customer_data
      {
        "Customer.FirstName": @data.fetch(:first_name, ''),
        "Customer.Surname": @data.fetch(:last_name, ''),
        "Customer.Address": @data.fetch(:building_street, ''),
        "Customer.Town": @data.fetch(:town_city, ''),
        "Customer.County": @data.fetch(:county, ''),
        "Customer.Postcode": @data.fetch(:postcode, ''),
        "Customer.Email": @data.fetch(:email_address, ''),
        "Customer.Phone": @data.fetch(:phone, '')
      }
    end

    def constant_data
      {
        db: 'hmcts',
        Type: 'Complaint',
        Format: 'json',
        RequestMethod: 'Form',
        Team: 'INBOX',
        "Case.ContactMethod": 'Online - gov.uk'
      }
    end
  end
end
