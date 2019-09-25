FactoryBot.define do
  factory :attachment do
    encryption_key do
      Base64.strict_encode64(
        "\xA1\xF3\x10\xC6\x04$\xDD\xEE\xDAV\x9EM9\x99<ipr\x10yzk\xEE\xF1#\xDF\x8E\xE2j\xEC\xB2\x8B"
      )
    end
    encryption_iv do
      Base64.strict_encode64(
        "\xCA\fH\xFC\xBE;[IZ[/\"{\xC7\xD8\xF4"
      )
    end
    url { 'https://cloud-platform-73fd040f8e31655e740b08a2ef9f1510.s3.eu-west-2.amazonaws.com/28d/1050367152b3aa91e6b4d7cd2670c2e66faf0f629ae9cdd2823774d54aa939e7?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIA27HJSWAHM3S2M67I%2F20190924%2Feu-west-2%2Fs3%2Faws4_request&X-Amz-Date=20190924T160834Z&X-Amz-Expires=900&X-Amz-SignedHeaders=host&X-Amz-Signature=152a75762015abb11f19e903d32b877a772e9e0dce901fe3ac25bcca2a07743b' }
    identifier { SecureRandom.uuid }
    mimetype { 'text/plain' }
    filename { 'test.txt' }
  end
end
