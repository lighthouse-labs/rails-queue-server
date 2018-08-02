class CreateLectures < ActiveRecord::Migration[5.0]
  def change

    create_table :lectures do |t|
      t.references :presenter
      t.references :cohort, foreign_key: true
      t.references :activity, foreign_key: true
      t.string :day, limit: 5
      t.string :subject, limit: 1000
      t.string :presenter_name
      t.text :body
      t.text :teacher_notes
      t.string :youtube_url, limit: 500
      t.string :file_name
      t.string :file_type
      t.timestamps
    end
  end
end
