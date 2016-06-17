class RenameNotesToTeacherNotesOnEvaluation < ActiveRecord::Migration
  def change
    rename_column :evaluations, :notes, :teacher_notes
  end
end
