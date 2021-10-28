module Presenter
  class Complaint
    def initialize(form_builder_payload:, attachments:)
      @submission_answers = form_builder_payload.fetch(:submissionAnswers)
      @attachments = attachments
    end

    def optics_payload
      {
        Team: submission_answers.fetch(:complaint_location),
        RequestDate: request_date,
        Details: submission_answers.fetch(:complaint_details, ''),
        Reference: submission_answers.fetch(:case_number, '')
      }.merge(constant_data, customer_data, *attachments_data)
    end

    private

    attr_reader :submission_answers, :attachments

    def request_date
      time = submission_answers.fetch(:submissionDate, (Time.now.to_i * 1000).to_s)
      Time.at(time.to_s.to_i / 1000).strftime('%Y-%m-%d')
    end

    # rubocop:disable Metrics/MethodLength
    def customer_data
      {
        'Customer.FirstName': submission_answers.fetch(:first_name, ''),
        'Customer.Surname': submission_answers.fetch(:last_name, ''),
        'Customer.Address': submission_answers.fetch(:building_street, ''),
        'Customer.Town': submission_answers.fetch(:town_city, ''),
        'Customer.County': submission_answers.fetch(:county, ''),
        'Customer.Postcode': submission_answers.fetch(:postcode, ''),
        'Customer.Email': submission_answers.fetch(:email_address, ''),
        'Customer.Phone': submission_answers.fetch(:phone, ''),
        'Impact': submission_answers.fetch(:impact, ''),
        'ActionRequested': submission_answers.fetch(:action_requested, '')
      }
    end
    # rubocop:enable Metrics/MethodLength

    def attachments_data
      attachments.map.with_index do |attachment, index|
        document_prefix = "Document#{index + 1}"

        {
          "#{document_prefix}.Name": attachment.filename,
          "#{document_prefix}.MimeType": attachment.mimetype,
          "#{document_prefix}.URL": attachment.exposed_url,
          "#{document_prefix}.URLLoadContent": true
        }
      end
    end

    def constant_data
      {
        db: 'hmcts',
        Type: 'Complaint',
        Format: 'json',
        RequestMethod: 'Online - gov.uk',
        'PartyContextManageCases': 'Main'
      }
    end
  end
end
