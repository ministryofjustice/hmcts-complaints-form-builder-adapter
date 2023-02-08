require 'net/http'

module Usecase
  class DownloadAttachment
    class ClientError < StandardError; end

    def initialize(identifier:)
      @identifier = identifier
    end

    def call
      result = HTTParty.get(uri)

      return result.body if result.success?

      raise ClientError, result
    end

    private

    attr_reader :identifier

    def attachment
      @attachment ||= Attachment.find_by(identifier:)
    end

    def uri
      URI(attachment.url)
    end
  end
end
