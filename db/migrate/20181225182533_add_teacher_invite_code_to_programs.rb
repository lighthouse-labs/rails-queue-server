class AddTeacherInviteCodeToPrograms < ActiveRecord::Migration[5.0]
  def up
    add_column :programs, :teacher_invite_code, :string

    Program.first&.update teacher_invite_code: ENV['TEACHER_INVITE_CODE']
  end
  def down
    add_column :programs, :teacher_invite_code, :string
  end
end
