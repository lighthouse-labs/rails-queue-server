class AddDeletedAtToActivityFeedbacks < ActiveRecord::Migration[5.0]
  def change
    add_column :activity_feedbacks, :deleted_at, :datetime
    add_index :activity_feedbacks, :deleted_at

    ActivityFeedback.reset_column_information
  end
end
