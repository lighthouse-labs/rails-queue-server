class AddZoomHostIdToVideoConferences < ActiveRecord::Migration[5.0]
  def change
    add_column :video_conferences, :zoom_host_id, :string
  end
end
