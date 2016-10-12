class AddHomeworkToActivities < ActiveRecord::Migration[5.0]
  def change
    add_column :activities, :homework, :boolean
  end
end
