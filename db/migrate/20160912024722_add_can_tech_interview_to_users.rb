class AddCanTechInterviewToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :can_tech_interview, :boolean
  end
end
