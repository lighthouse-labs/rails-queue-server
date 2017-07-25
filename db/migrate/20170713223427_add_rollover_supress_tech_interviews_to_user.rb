class AddRolloverSuppressTechInterviewsToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :suppress_tech_interviews, :boolean
  end
end
