class AddIndicesToFeedbacks < ActiveRecord::Migration[5.0]
  def change
    add_index :feedbacks, [:feedbackable_id, :feedbackable_type]
    add_index :feedbacks, :student_id
    add_index :feedbacks, :teacher_id
  end
end
