class CreateEvaluations < ActiveRecord::Migration
  def change
    create_table :evaluations do |t|
      t.integer :project_id
      t.integer :student_id
      t.integer :teacher_id
      t.boolean :accepted

      t.timestamps null: false
    end
  end
end
