class CreateActivityFeedbacks < ActiveRecord::Migration
  def change
    create_table :activity_feedbacks do |t|
      t.references :activity, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.integer :sentiment # -1, 0, +1
      t.integer :rating
      t.text :detail

      t.timestamps null: false
    end
  end
end
