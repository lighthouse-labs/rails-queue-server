class AddPasswordToVideoConferences < ActiveRecord::Migration[5.0]
  def change
    add_column :video_conferences, :password, :string
  end
end
