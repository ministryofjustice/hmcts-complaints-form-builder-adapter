module Usecase
  class SweepDatabase
    def initialize(attachments_gateway:)
      @attachments_gateway = attachments_gateway
    end

    def call(time_ago)
      @attachments_gateway.delete_data_since(time_ago)
    end
  end
end
