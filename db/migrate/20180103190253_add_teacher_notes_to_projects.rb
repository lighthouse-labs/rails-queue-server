class AddTeacherNotesToProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :sections, :teacher_notes, :text
  end
end
