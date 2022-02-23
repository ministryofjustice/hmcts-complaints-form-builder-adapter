desc "
Replay an attachment
Usage
rake replay_attachment[<identifier>]
"
task :replay_attachment, [:identifier] => :environment do |_t, args|
  attachment = Attachment.find_by(identifier: args[:identifier])
  if attachment.present?
    file = HTTParty.get(attachment.url).body
    begin
      decrypted_file_data = Cryptography.new(
        encryption_key: Base64.strict_decode64(attachment.encryption_key),
        encryption_iv: Base64.strict_decode64(attachment.encryption_iv)
      ).decrypt(file: file)
    rescue OpenSSL::Cipher::CipherError
      puts 'Unable to decrypt. File access has possibly expired'
    end

    puts 'Resending attachment data'
    send_data(
      decrypted_file_data,
      type: attachment.mimetype,
      disposition: "attachment; filename=#{attachment.filename}"
    )
  else
    puts "Unable to find attachment with identifier: #{identifier}"
  end
end
