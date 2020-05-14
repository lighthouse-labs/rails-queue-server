class CreateAssistances < ActiveRecord::Migration[5.0]
  def change
    create_table :assistances do |t|
      t.string    :assistor_uid

      t.datetime  :start_at
      t.datetime  :end_at
      t.text      :notes
      t.datetime  :created_at
      t.datetime  :updated_at
      t.integer   :rating
      t.text      :student_notes
      t.boolean   :flag
      t.string    :conference_link
      t.string    :conference_type
      t.index     :assistor_uid
    end
  end
end
