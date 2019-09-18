module Presenter
  class Complaint
    def initialize(form_builder_payload:)
      @data = form_builder_payload.fetch(:submissionAnswers)
    end

    def optics_payload
      {
        Team: @data.fetch(:complaint_location, 'INBOX'),
        RequestDate: request_date,
        Details: @data.fetch(:complaint_details, ''),
        Reference: @data.fetch(:case_number, '')
      }.merge(constant_data, customer_data)
    end

    private

    def request_date
      time = @data.fetch(:submissionDate, (Time.now.to_i * 1000).to_s)
      Time.at(time.to_s.to_i / 1000).strftime('%Y-%m-%d')
    end

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
        RequestMethod: 'Online - gov.uk'
      }
    end
  end
end
