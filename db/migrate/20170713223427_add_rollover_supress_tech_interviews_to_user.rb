class AddRolloverSupressTechInterviewsToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :supress_tech_interviews, :boolean
  end
end
