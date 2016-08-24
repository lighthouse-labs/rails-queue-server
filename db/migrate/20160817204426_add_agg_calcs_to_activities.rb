class AddAggCalcsToActivities < ActiveRecord::Migration
  def up
    add_column :activities, :average_rating, :float
    add_column :activities, :average_time_spent, :integer
  end
end
