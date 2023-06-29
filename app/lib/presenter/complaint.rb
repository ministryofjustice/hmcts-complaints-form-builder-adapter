module Presenter
  class Complaint < BasePresenter
    def initialize(form_builder_payload:, attachments:, api_version:)
      super(form_builder_payload:, api_version:)
      @attachments = attachments
    end

    # rubocop:disable Metrics/MethodLength,
    def optics_payload
      Rails.logger.warn("api version: #{@api_version}")

      case @api_version
      when 'v1'
        {
          Team: submission_answers.fetch(:complaint_location),
          AssignedTeam: submission_answers.fetch(:complaint_location),
          AssignedTeamSS: submission_answers.fetch(:complaint_location),
          RequestDate: request_date,
          Details: submission_answers.fetch(:complaint_details, ''),
          Reference: submission_answers.fetch(:case_number, '')
        }.merge(constant_data, customer_data, *attachments_data)
      when 'v2'
        {
          # rubocop:disable Naming/VariableNumber
          Team: submission_answers.fetch(:courtortribunalyourcomplaintisabout_autocomplete_1),
          AssignedTeam: submission_answers.fetch(:courtortribunalyourcomplaintisabout_autocomplete_1),
          AssignedTeamSS: submission_answers.fetch(:courtortribunalyourcomplaintisabout_autocomplete_1),
          RequestDate: request_date,
          Details: submission_answers.fetch(:yourcomplaint_textarea_1, ''),
          Reference: submission_answers.fetch(:casenumber_text_1, '')
        }.merge(constant_data, customer_data_v2, *attachments_data)
        # rubocop:enable Naming/VariableNumber
      end
    end
    # rubocop:enable Metrics/MethodLength

    private

    attr_reader :attachments

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

    # rubocop:disable Metrics/MethodLength, Naming/VariableNumber
    def customer_data_v2
      {
        'Customer.FirstName': submission_answers.fetch(:yourname_text_1, ''),
        'Customer.Surname': submission_answers.fetch(:yourname_text_2, ''),
        'Customer.Address': '',
        'Customer.Town': '',
        'Customer.County': '',
        'Customer.Postcode': '',
        'Customer.Email': submission_answers.fetch(:youremailaddress_email_1, ''),
        'Customer.Phone': '',
        'Impact': submission_answers.fetch(:howhasthisaffectedyou_textarea_1, ''),
        'ActionRequested': submission_answers.fetch(:whatcanwedotoputthisright_textarea_1, '')
      }
    end
    # rubocop:enable Metrics/MethodLength, Naming/VariableNumber
  end
end
