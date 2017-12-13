class AddYoutubeLinkToRecordings < ActiveRecord::Migration[5.0]
  def change
    add_column :recordings, :youtube_link, :string
  end
end
