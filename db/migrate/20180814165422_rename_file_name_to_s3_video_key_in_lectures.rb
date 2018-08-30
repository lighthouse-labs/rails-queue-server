class RenameFileNameToS3VideoKeyInLectures < ActiveRecord::Migration[5.0]
  def up
    rename_column :lectures, :file_name, :s3_video_key

  end

  def down
    rename_column :lectures, :s3_video_key, :file_name
  end

end
