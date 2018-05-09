class AddArchivedToRecordingsAndActivityMsgs < ActiveRecord::Migration[5.0]
  def change
    add_column :activity_messages, :archived, :boolean
    add_column :recordings, :archived, :boolean
  end
end
