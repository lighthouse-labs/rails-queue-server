class DropRecordings < ActiveRecord::Migration[5.0]
  def change
    drop_table :recordings
  end
end
