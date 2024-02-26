module Presenter
  class Complaint < BasePresenter
    def initialize(form_builder_payload:, attachments:, api_version:)
      super(form_builder_payload:, api_version:)
      @attachments = attachments
    end

    def optics_payload
      {
        Team: submission_answers.fetch(:courtortribunalyourcomplaintisabout_autocomplete_1),
        AssignedTeam: submission_answers.fetch(:courtortribunalyourcomplaintisabout_autocomplete_1),
        AssignedTeamSS: submission_answers.fetch(:courtortribunalyourcomplaintisabout_autocomplete_1),
        RequestDate: request_date,
        Details: submission_answers.fetch(:yourcomplaint_textarea_1, ''),
        Reference: submission_answers.fetch(:casenumber_text_1, '')
      }.merge(constant_data, customer_data, *attachments_data)
    end

    private

    attr_reader :attachments

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
        PartyContextManageCases: 'Main'
      }
    end

    def customer_data
      {
        'Customer.FirstName': submission_answers.fetch(:yourname_text_1, ''),
        'Customer.Surname': submission_answers.fetch(:yourname_text_2, ''),
        'Customer.Email': submission_answers.fetch(:youremailaddress_email_1, ''),
        'Customer.Phone': submission_answers.fetch(:yourphonenumber_text_1, ''),
        Impact: submission_answers.fetch(:howhasthisaffectedyou_textarea_1, ''),
        ActionRequested: submission_answers.fetch(:whatcanwedotoputthisright_textarea_1, '')
      }.merge(
        customer_address
      )
    end

    # TODO: temporarily until en/cy forms are updated, support both address formats
    # rubocop:disable Metrics/MethodLength
    def customer_address
      if address_component.present?
        {
          'Customer.Address': [address_component[:address_line_one], address_component[:address_line_two]].compact_blank.join(', '),
          'Customer.Town': address_component.fetch(:city, ''),
          'Customer.County': address_component.fetch(:county, ''),
          'Customer.Postcode': address_component.fetch(:postcode, '')
        }
      else
        {
          'Customer.Address': submission_answers.fetch(:youraddress_text_1, ''),
          'Customer.Town': submission_answers.fetch(:youraddress_text_2, ''),
          'Customer.County': submission_answers.fetch(:youraddress_text_3, ''),
          'Customer.Postcode': submission_answers.fetch(:youraddress_text_4, '')
        }
      end
    end
    # rubocop:enable Metrics/MethodLength

    def address_component
      @address_component ||= submission_answers.fetch(:youraddress_address_1, {}).with_indifferent_access
    end
  end
end
