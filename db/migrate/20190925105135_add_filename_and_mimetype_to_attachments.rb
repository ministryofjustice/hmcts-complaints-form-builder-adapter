class AddFilenameAndMimetypeToAttachments < ActiveRecord::Migration[6.0]
  def change
    add_column :attachments, :filename, :text
    add_column :attachments, :mimetype, :text
  end
end
