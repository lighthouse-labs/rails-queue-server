class AddArchivedToSections < ActiveRecord::Migration[5.0]
  def change
    add_column :sections, :archived, :boolean
  end
end
