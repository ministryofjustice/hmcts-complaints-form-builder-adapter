require 'rails_helper'

RSpec.describe Presenter::Correspondence do
  subject(:presenter) do
    described_class.new(form_builder_payload: base_payload)
  end

  describe '#optics_payload' do
    let(:constant_data) do
      {
        db: Presenter::Correspondence::DB,
        Team: Presenter::Correspondence::TEAM,
        Type: Presenter::Correspondence::TYPE,
        'Case.ContactMethod': Presenter::Correspondence::CONTACT_METHOD
      }
    end
    let(:base_payload) do
      {
        serviceSlug: 'money-claim-queries',
        submissionId: submission_id,
        submissionAnswers:
        {
          ClaimNumber: 'CaseReferenceYes',
          NewOrExistingClaim: 'existing-claim',
          CaseReference: 'some reference',
          ApplicantType: 'claimant',
          MessageContent: 'some message body thing',
          ServiceType: 'money-claim',
          ClientFirstName: 'Darth',
          ClientLastName: 'Maul',
          ContactPhone: '5555555555'
        }.merge(input_payload)
      }
    end
    let(:submission_id) { '891c837c-adef-4854-8bd0-d681577f381e' }

    context 'applicant type' do
      context 'when claimant' do
        let(:input_payload) do
          { ApplicantType: 'claimant' }
        end

        it 'returns "A"' do
          expect(presenter.optics_payload[:ApplicantType]).to eq('A')
        end
      end

      context 'when defendant' do
        let(:input_payload) do
          { ApplicantType: 'defendant' }
        end

        it 'returns "B"' do
          expect(presenter.optics_payload[:ApplicantType]).to eq('B')
        end
      end

      %w[representing-defendant representing-claimant].each do |applicant_type|
        context "when #{applicant_type}" do
          let(:input_payload) do
            { ApplicantType: applicant_type }
          end

          it 'returns "C"' do
            expect(presenter.optics_payload[:ApplicantType]).to eq('C')
          end
        end
      end
    end

    context 'case reference' do
      context 'when there is an existing claim' do
        let(:input_payload) do
          {
            NewOrExistingClaim: 'existing-claim',
            ClaimNumber: 'CaseReferenceYes',
            CaseReference: 'some reference'
          }
        end

        it 'returns the case reference' do
          expect(presenter.optics_payload[:CRef]).to eq('some reference')
        end
      end

      context 'when it is a new claim' do
        let(:input_payload) do
          {
            NewOrExistingClaim: 'new-claim',
            ClaimNumber: 'CaseReferenceNo',
            CaseReference: 'some reference that should not be there'
          }
        end

        it 'returns blank string the case reference' do
          expect(presenter.optics_payload[:CRef]).to eq('')
        end
      end
    end

    context 'customer party context' do
      %w[claimant defendant].each do |applicant_type|
        context "when applicant type is #{applicant_type}" do
          let(:input_payload) do
            { ApplicantType: applicant_type }
          end

          it 'returns "Main"' do
            expect(presenter.optics_payload[:CustomerPartyContext]).to eq('Main')
          end
        end
      end

      %w[representing-defendant representing-claimant].each do |applicant_type|
        context "when applicant type is #{applicant_type}" do
          let(:input_payload) do
            { ApplicantType: applicant_type }
          end

          it 'returns "Agent"' do
            expect(presenter.optics_payload[:CustomerPartyContext]).to eq('Agent')
          end
        end
      end
    end

    context 'query type' do
      context 'when QueryTypeDefendant' do
        let(:input_payload) do
          { QueryTypeDefendant: query_type }
        end

        context 'when court judgement' do
          let(:query_type) { 'court-judgement' }

          it 'returns "A"' do
            expect(presenter.optics_payload[:QueryType]).to eq('A')
          end
        end

        context 'when court hearing' do
          let(:query_type) { 'defendant-court-hearing' }

          it 'returns "B"' do
            expect(presenter.optics_payload[:QueryType]).to eq('B')
          end
        end

        context 'when other' do
          let(:query_type) { 'defendant-other' }

          it 'returns "E"' do
            expect(presenter.optics_payload[:QueryType]).to eq('E')
          end
        end
      end

      context 'when QueryTypeClaimant' do
        let(:input_payload) do
          { QueryTypeClaimant: query_type }
        end

        context 'when court hearing' do
          let(:query_type) { 'claimant-court-hearing' }

          it 'returns "B"' do
            expect(presenter.optics_payload[:QueryType]).to eq('B')
          end
        end

        context 'when a progress update' do
          let(:query_type) { 'progress-update' }

          it 'returns "C"' do
            expect(presenter.optics_payload[:QueryType]).to eq('C')
          end
        end

        context 'change a money claim' do
          let(:query_type) { 'change-claim' }

          it 'returns "D"' do
            expect(presenter.optics_payload[:QueryType]).to eq('D')
          end
        end

        context 'when other' do
          let(:query_type) { 'claimant-other' }

          it 'returns "E"' do
            expect(presenter.optics_payload[:QueryType]).to eq('E')
          end
        end

        context 'when the claim has been paid' do
          let(:query_type) { 'claim-paid' }

          it 'returns "F"' do
            expect(presenter.optics_payload[:QueryType]).to eq('F')
          end
        end

        context 'claim has not been paid' do
          let(:query_type) { 'claim-not-paid' }

          it 'returns "G"' do
            expect(presenter.optics_payload[:QueryType]).to eq('G')
          end
        end
      end
    end

    context 'service type' do
      context 'when a money claim' do
        let(:input_payload) do
          { ServiceType: 'money-claim' }
        end

        it 'returns "A"' do
          expect(presenter.optics_payload[:ServiceType]).to eq('A')
        end
      end

      context 'when other other query' do
        let(:input_payload) do
          { ServiceType: 'other-query' }
        end

        it 'returns a blank string' do
          expect(presenter.optics_payload[:ServiceType]).to eq('')
        end
      end
    end

    context 'self representing' do
      let(:today) { Time.now.strftime('%d/%m/%Y') }
      let(:input_payload) do
        {
          Applicant1FirstName: 'Qui Gon',
          Applicant1LastName: 'Jinn',
          Applicant1Email: 'quigon@jedi-temple.com',
          Applicant1Phone: '5555555555',
          NewOrExistingClaim: 'new-claim',
          ClaimNumber: 'CaseReferenceNo',
          QueryTypeClaimant: 'court-judgement'
        }
      end
      let(:expected_payload) do
        {
          ApplicantType: 'A',
          CRefYesNo: 'No',
          CRef: '',
          CustomerPartyContext: 'Main',
          Details: 'some message body thing',
          QueryType: 'A',
          ServiceType: 'A',
          ExternalId: submission_id,
          'Applicant1.Forename1': 'Qui Gon',
          'Applicant1.Name': 'Jinn',
          'Applicant1.Email': 'quigon@jedi-temple.com',
          'Applicant1.Phone': '5555555555',
          'Case.ReceivedDate': today,
          'CaseContactPostcode.Subject': '',
          'CaseContactCustom17.Representative': '',
          'CaseContactCustom18.Subject': '',
          'Agent.Forename1': '',
          'Agent.Name': '',
          'Agent.Email': '',
          'Agent.Phone': ''
        }.merge(constant_data)
      end

      it 'sets the applicant contact details correctly' do
        expect(presenter.optics_payload).to eq(expected_payload)
      end
    end

    context 'correspondence type' do
      let(:input_payload) { {} }

      context 'when type is not set in the environment' do
        it 'defaults to use the type in the model' do
          expect(presenter.optics_payload[:Type]).to eq(Presenter::Correspondence::TYPE)
        end
      end

      context 'when type is set in the environment' do
        let(:correspondence_type) { 'foo' }
        let(:constant_data) do
          constant_data.merge({ Type: correspondence_type })
        end

        before do
          allow(ENV).to receive(:[]).with('CORRESPONDENCE_TYPE').and_return(correspondence_type)
        end

        it 'uses the type from the environment' do
          expect(presenter.optics_payload[:Type]).to eq(correspondence_type)
        end
      end
    end

    context 'representing' do
      let(:today) { Time.now.strftime('%d/%m/%Y') }
      let(:input_payload) do
        {
          ApplicantType: 'representing-claimant',
          ApplicantFirstName: 'Qui Gon',
          ApplicantLastName: 'Jinn',
          ApplicantEmail: 'quigon@jedi-temple.com',
          ApplicantPhone: '5555555555',
          CompanyName: 'Jedi Council',
          QueryTypeClaimant: 'claimant-other',
          ClientPostcode: 'W1C 1CA'
        }
      end
      let(:expected_payload) do
        {
          ApplicantType: 'C',
          CRefYesNo: 'Yes',
          CRef: 'some reference',
          CustomerPartyContext: 'Agent',
          Details: 'some message body thing',
          QueryType: 'E',
          ServiceType: 'A',
          ExternalId: submission_id,
          'Applicant1.Forename1': 'Darth',
          'Applicant1.Name': 'Maul',
          'Applicant1.Email': '',
          'Applicant1.Phone': '',
          'Case.ReceivedDate': today,
          'CaseContactPostcode.Subject': 'W1C 1CA',
          'CaseContactCustom17.Representative': 'Jedi Council',
          'CaseContactCustom18.Subject': '',
          'Agent.Forename1': 'Qui Gon',
          'Agent.Name': 'Jinn',
          'Agent.Email': 'quigon@jedi-temple.com',
          'Agent.Phone': '5555555555'
        }.merge(constant_data)
      end

      it 'sets the agent contact details correctly' do
        expect(presenter.optics_payload).to eq(expected_payload)
      end
    end

    context 'received date' do
      let(:today) { Time.now.strftime('%d/%m/%Y') }
      let(:input_payload) { {} }

      it 'returns a the date correctly formatted' do
        expect(presenter.optics_payload[:'Case.ReceivedDate']).to eq(today)
      end
    end
  end
end
