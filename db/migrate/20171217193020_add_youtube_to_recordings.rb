class AddYoutubeToRecordings < ActiveRecord::Migration[5.0]
  def change
    add_column :recordings, :youtube, :boolean
  end
end
