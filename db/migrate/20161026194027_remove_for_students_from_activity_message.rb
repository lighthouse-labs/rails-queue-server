class RemoveForStudentsFromActivityMessage < ActiveRecord::Migration[5.0]
  def change
    remove_column :activity_messages, :for_students, :boolean
  end
end
