class AddCurriculumTeamEmailToPrograms < ActiveRecord::Migration[5.0]
  def change
    add_column :programs, :curriculum_team_email, :string
  end
end
