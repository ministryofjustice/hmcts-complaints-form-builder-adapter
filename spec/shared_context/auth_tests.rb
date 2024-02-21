RSpec.shared_context 'when authentication required', when_authentication_required: :metadata do
  let(:url) { raise "set the url to test auth vs ie. 'let(:url) { '/v2/complaint'}' " }

  it 'requires authentication' do
    post url
    expect(response).to have_http_status(:unauthorized)
  end
end
