class AddStudentNotesToEvaluation < ActiveRecord::Migration
  def change
    add_column :evaluations, :student_notes, :text
  end
end
