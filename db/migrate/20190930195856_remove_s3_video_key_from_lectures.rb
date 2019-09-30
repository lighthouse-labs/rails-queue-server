class RemoveS3VideoKeyFromLectures < ActiveRecord::Migration[5.0]
  def change
    remove_column :lectures, :s3_video_key
  end
end
