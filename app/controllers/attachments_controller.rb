class AttachmentsController < ActionController::API
  def show
    attachment = Attachment.find_by(identifier: params.fetch(:id))

    decrypted_file_data = Cryptography.new(
      encryption_key: Base64.strict_decode64(attachment.encryption_key),
      encryption_iv: Base64.strict_decode64(attachment.encryption_iv)
    ).decrypt(file: HTTParty.get(attachment.url).body)

    render :ok, body: decrypted_file_data, headers: {
      'Content-Type' => 'text/plain',
      'Content-disposition' => 'attachment; filename=test.txt'
    }
  end
end
