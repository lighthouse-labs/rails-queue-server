class CreateActivityAnswers < ActiveRecord::Migration[5.0]
  def change
    create_table :activity_answers do |t|
      t.references :activity, foreign_key: true
      t.references :user, foreign_key: true

      t.string :question_key
      t.text :answer_text
      t.boolean :toggled

      t.timestamps
    end
  end
end
