class AddContentFilePathToProjects < ActiveRecord::Migration
  def change
    add_column :sections, :content_file_path, :string
  end
end
