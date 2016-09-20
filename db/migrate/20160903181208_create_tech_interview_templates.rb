class CreateTechInterviewTemplates < ActiveRecord::Migration[5.0]
  def change
    create_table :tech_interview_templates do |t|
      t.string :uuid
      t.integer :week

      t.string :content_file_path
      t.references :content_repository

      t.text :description
      t.text :teacher_notes

      t.timestamps
    end
  end
end
