RSpec.shared_examples 'an application job' do
  let(:submission_id) { SecureRandom.uuid }

  context 'submission exists in database' do
    before do
      ProcessedSubmission.create(submission_id: submission_id)
    end

    it 'should not process the submission again' do
      expect(create_case).not_to receive(:execute)
      jobs.perform(form_builder_payload: input)
    end
  end

  context 'submission not in db but exists in optics' do
    let(:result) { double(success?: true) }

    before do
      allow(gateway).to receive(:get_case_attribute).and_return(result)
    end

    it 'should not process the submission again' do
      expect(create_case).not_to receive(:execute)
      jobs.perform(form_builder_payload: input)
    end

    it 'should create the processed submission record in the db' do
      jobs.perform(form_builder_payload: input)
      expect(ProcessedSubmission.find_by(submission_id: submission_id)).to be_present
    end
  end

  context 'when the case does not exist in database or in optics' do
    let(:result) { double(success?: false) }

    before do
      allow(gateway).to receive(:get_case_attribute).and_return(result)
    end

    it 'should process the submission' do
      expect(create_case).to receive(:execute)
      jobs.perform(form_builder_payload: input)
    end

    it 'should create the processed submission record in the db' do
      jobs.perform(form_builder_payload: input)
      expect(ProcessedSubmission.find_by(submission_id: submission_id)).to be_present
    end
  end

  context 'when there is an error communicating with OPTICS' do
    let(:error) { Gateway::Optics::ClientError.new('some error message') }

    before do
      allow(gateway).to receive(:get_case_attribute).and_raise(error)
    end

    it 'should not process the submission' do
      expect(create_case).not_to receive(:execute)
      expect(Raven).to receive(:capture_exception).with(error)
      expect(Rails.logger).to receive(:warn).with(error.message)
      expect { jobs.perform(form_builder_payload: input) }.to raise_error(Gateway::Optics::ClientError)
    end
  end
end
