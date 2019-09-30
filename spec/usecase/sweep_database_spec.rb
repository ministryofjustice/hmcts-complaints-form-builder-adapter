require 'rails_helper'

RSpec.describe Usecase::SweepDatabase do
  describe '#call' do
    subject(:sweep_database) do
      described_class.new(attachments_gateway: attachments_gateway)
    end

    let(:attachments_gateway) { instance_double('Gateway::Attachments', delete_data_since: true) }
    let(:max_data_age) { 7.days.ago }

    it 'calls delete_data_since on the gateway' do
      sweep_database.call(max_data_age)
      expect(attachments_gateway).to have_received(:delete_data_since).with(max_data_age).once
    end
  end
end
