class RemoveRecordingsFromPrograms < ActiveRecord::Migration[5.0]
  def change
    remove_column :programs, :recordings_folder
    remove_column :programs, :recordings_bucket
  end
end
