class AddArchivedToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :archived, :boolean
  end
end
