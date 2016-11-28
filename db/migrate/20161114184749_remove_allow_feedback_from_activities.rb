class RemoveAllowFeedbackFromActivities < ActiveRecord::Migration[5.0]
  def change
    remove_column :activities, :allow_feedback, :boolean
  end
end
