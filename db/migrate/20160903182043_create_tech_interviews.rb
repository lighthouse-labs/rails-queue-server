class CreateTechInterviews < ActiveRecord::Migration[5.0]
  def change
    create_table :tech_interviews do |t|

      t.references :tech_interview_template, foreign_key: true
      t.belongs_to :interviewee
      t.belongs_to :interviewer

      t.datetime :started_at
      t.datetime :completed_at

      t.integer :total_answered
      t.integer :total_asked
      t.float   :average_score

      t.text :feedback
      t.text :internal_notes

      t.timestamps
    end
  end
end
