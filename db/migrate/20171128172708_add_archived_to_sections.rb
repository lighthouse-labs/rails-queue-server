class AddArchivedToSections < ActiveRecord::Migration[5.0]
  def change
    add_column :sections, :archived, :boolean
    add_column :tech_interview_templates, :archived, :boolean
  end
end
