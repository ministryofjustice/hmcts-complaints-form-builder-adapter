require 'rails_helper'

describe 'Downloading an attachment', type: :request do
  let(:file_data) { File.read(file_fixture('hello.txt')) }
  let(:attachment) { create(:attachment) }

  let(:encrypted_file_data) do
    encryption_key = Base64.strict_decode64(attachment.encryption_key)
    encryption_iv = Base64.strict_decode64(attachment.encryption_iv)
    Cryptography.new(
      encryption_key: encryption_key,
      encryption_iv: encryption_iv
    ).encrypt(file: file_data)
  end

  before do
    stub_request(:get, 'https://some-bucket.s3.eu-west-2.amazonaws.com/28d/1050367152b3aa91e6b4d7cd2670c2e66faf0f629ae9cdd2823774d54aa939e7?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIA27HJSWAHM3S2M67I/20190924/eu-west-2/s3/aws4_request&X-Amz-Date=20190924T160834Z&X-Amz-Expires=900&X-Amz-Signature=152a75762015abb11f19e903d32b877a772e9e0dce901fe3ac25bcca2a07743b&X-Amz-SignedHeaders=host')
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(status: 200, body: encrypted_file_data, headers: {})

    get "/v1/attachments/#{attachment.identifier}"
  end

  it 'returns 201 on a valid post' do
    expect(response).to have_http_status(:ok)
  end

  it 'returns a decrypted file' do
    expect(response.body).to eq(file_data)
  end

  it 'returns the correct mimetype as a header' do
    expect(response.headers['Content-Type']).to include(attachment.mimetype)
  end

  it 'returns the correct filename as a header' do
    expect(response.headers['Content-Disposition']).to include(
      "attachment; filename=#{attachment.filename}"
    )
  end
end
