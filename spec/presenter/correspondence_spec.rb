require 'rails_helper'

RSpec.describe Presenter::Correspondence do
  subject(:presenter) do
    described_class.new(form_builder_payload: base_payload)
  end

  describe '#optics_payload' do
    let(:base_payload) do
      {
        serviceSlug: 'money-claim-queries',
        submissionId: '891c837c-adef-4854-8bd0-d681577f381e',
        submissionAnswers:
        {
          NewOrExistingClaim: 'Yes',
          CaseReference: 'some reference',
          ApplicantType: 'claimant',
          MessageContent: 'some message body thing',
          ApplicantFirstName: 'Qui Gon',
          ApplicantLastName: 'Jinn',
          ContactEmail: 'quigon@jedi-temple.com',
          CompanyName: 'Jedi Council',
          ServiceType: 'money-claim'
        }.merge(input_payload)
      }
    end

    context 'when case reference is "Yes"' do
      let(:input_payload) do
        {
          NewOrExistingClaim: 'Yes',
          CaseReference: 'some reference'
        }
      end

      it 'returns the case reference' do
        expect(presenter.optics_payload[:CRef]).to eq('some reference')
      end
    end

    context 'when case reference is "No"' do
      let(:input_payload) do
        {
          NewOrExistingClaim: 'No',
          CaseReference: 'some reference that should not be there'
        }
      end

      it 'returns blank string the case reference' do
        expect(presenter.optics_payload[:CRef]).to eq('')
      end
    end

    context 'when there is no representative' do
      let(:input_payload) do
        { ApplicantType: 'defendant' }
      end

      it 'returns "Main" for CustomerPartyContext' do
        expect(presenter.optics_payload[:CustomerPartyContext]).to eq('Main')
      end
    end

    context 'when there is a representative' do
      let(:input_payload) do
        { ApplicantType: 'representing-claimant' }
      end

      it 'returns a blank string for the customer party context' do
        expect(presenter.optics_payload[:CustomerPartyContext]).to eq('Agent')
      end
    end

    context 'when QueryTypeDefendant is in the payload' do
      let(:query_type) { 'defendant-court-hearing' }
      let(:input_payload) do
        { QueryTypeDefendant: query_type }
      end

      it 'returns the QueryTypeDefendant for query type' do
        expect(presenter.optics_payload[:QueryType]).to eq(query_type)
      end
    end

    context 'when QueryTypeClaimant is the payload' do
      let(:query_type) { 'claimant-court-hearing' }
      let(:input_payload) do
        { QueryTypeClaimant: query_type }
      end

      it 'returns QueryTypeClaimant for query type' do
        expect(presenter.optics_payload[:QueryType]).to eq(query_type)
      end
    end

    context 'when neither QueryTypeClaimant or QueryTypeDefendant are there' do
      let(:input_payload) { {} }

      it 'returns a blank string for query type' do
        expect(presenter.optics_payload[:QueryType]).to eq('')
      end
    end
  end
end
