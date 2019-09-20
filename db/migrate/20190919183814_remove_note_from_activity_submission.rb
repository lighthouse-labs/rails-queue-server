class RemoveNoteFromActivitySubmission < ActiveRecord::Migration[5.0]
  def change
    remove_column :activity_submissions, :note
  end
end
