class AddLicensedToVideoConferences < ActiveRecord::Migration[5.0]
  def change
    add_column :video_conferences, :licensed, :boolean
  end
end
