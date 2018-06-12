class AddMilestoneToActivities < ActiveRecord::Migration[5.0]
  def change
    add_column :activities, :milestone, :boolean
  end
end
