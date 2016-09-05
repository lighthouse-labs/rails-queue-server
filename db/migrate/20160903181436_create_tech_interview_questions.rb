class CreateTechInterviewQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :tech_interview_questions do |t|

      t.string :uuid
      t.references :tech_interview_template, foreign_key: true
      t.references :outcome, foreign_key: true

      t.integer :sequence
      t.text :question
      t.text :answer
      t.text :notes

      t.integer :duration
      t.boolean :stretch

      t.boolean :archived

      t.timestamps
    end
  end
end
