class AddFileTypeToRecordings < ActiveRecord::Migration[5.0]
  def change
    add_column :recordings, :file_type, :string
  end
end
