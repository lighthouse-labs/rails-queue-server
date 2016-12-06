class RemoveCanTechInterviewFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :can_tech_interview, :boolean
  end
end
