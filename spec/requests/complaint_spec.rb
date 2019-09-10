describe 'Submitting a complaint', type: :request do
  it 'requires authentication' do
    post '/v1/complaint'
    expect(response).to have_http_status(:unauthorized)
  end

  it 'returns 201 on a valid post' do
    post '/v1/complaint', params: encrypted_body
    expect(response).to have_http_status(:created)
  end
end
