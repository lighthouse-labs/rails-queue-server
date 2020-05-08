class CreateFeedbacks < ActiveRecord::Migration[5.0]
  def change
    create_table :feedbacks do |t|
      t.string   :assistee_uid
      t.string   :assistor_uid
      t.integer  :technical_rating
      t.integer  :style_rating
      t.text     :notes
      t.integer  :feedbackable_id
      t.string   :feedbackable_type
      t.datetime :created_at
      t.datetime :updated_at
      t.float    :rating
      t.index    :assistor_uid
      t.index    :assistee_uid
    end
  end
end
