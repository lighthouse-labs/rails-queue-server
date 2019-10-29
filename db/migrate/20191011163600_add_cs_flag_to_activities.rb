class AddCsFlagToActivities < ActiveRecord::Migration[5.0]
  def change
    add_column :activities, :cs, :boolean
  end
end
