class CreateProgrammingTestAttempts < ActiveRecord::Migration[5.0]
  def change
    create_table :programming_test_attempts do |t|
      t.references :student, foreign_key: { to_table: :users }, null: false
      t.references :cohort, foreign_key: true, null: false
      t.references :programming_test, foreign_key: true, null: false

      t.timestamps
    end
  end
end
