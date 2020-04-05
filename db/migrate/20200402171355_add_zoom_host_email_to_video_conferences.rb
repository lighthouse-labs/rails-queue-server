class AddZoomHostEmailToVideoConferences < ActiveRecord::Migration[5.0]
  def change
    add_column :video_conferences, :zoom_host_email, :string
  end
end
