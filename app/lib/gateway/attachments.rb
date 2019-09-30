module Gateway
  class Attachments
    def delete_data_since(time_ago)
      Attachment.where('created_at < ?', time_ago).destroy_all.count
    end
  end
end
