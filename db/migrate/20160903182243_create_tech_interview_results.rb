class CreateTechInterviewResults < ActiveRecord::Migration[5.0]
  def change
    create_table :tech_interview_results do |t|
      t.references :tech_interview, foreign_key: true#, index: { name: 'index_ti_results_on_ti_id' }
      t.references :tech_interview_question, foreign_key: true#, index: { name: 'index_ti_question_results_on_ti_question_id' }
      t.text :question
      t.text :notes
      t.integer :score

      t.timestamps
    end
  end
end
