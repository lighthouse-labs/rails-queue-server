class AddMeetingNameToVideoConferences < ActiveRecord::Migration[5.0]
  def change
    add_column :video_conferences, :name, :string
  end
end
