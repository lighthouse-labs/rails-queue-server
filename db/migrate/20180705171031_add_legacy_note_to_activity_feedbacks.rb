class AddLegacyNoteToActivityFeedbacks < ActiveRecord::Migration[5.0]
  def change
    add_column :activity_feedbacks, :legacy_note, :boolean
  end
end
