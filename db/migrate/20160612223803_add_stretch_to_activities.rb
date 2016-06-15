class AddStretchToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :stretch, :boolean
  end
end
