class AddSubmissionIdToProcessedSubmissions < ActiveRecord::Migration[6.1]
  def change
    add_column :processed_submissions, :submission_id, :string
  end
end
