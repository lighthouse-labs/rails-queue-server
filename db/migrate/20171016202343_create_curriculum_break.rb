class CreateCurriculumBreak < ActiveRecord::Migration[5.0]
  def change
    create_table :curriculum_breaks do |t|
      t.timestamps
      t.string :name
      t.date :starts_on
      t.integer :num_weeks
      t.references :cohort, foreign_key: true
    end
  end
end
