class AddMoreIndicesToEvals < ActiveRecord::Migration[5.0]
  def change
    add_index :evaluations, :teacher_id
    add_index :evaluations, :student_id
    add_index :evaluations, :project_id
    add_index :evaluations, [:teacher_id, :state]
  end
end
