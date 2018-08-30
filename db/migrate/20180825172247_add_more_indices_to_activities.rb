class AddMoreIndicesToActivities < ActiveRecord::Migration[5.0]
  def change
    add_index :activities, :section_id
    add_index :activities, [:section_id, :stretch]
    add_index :activities, :day
  end
end
