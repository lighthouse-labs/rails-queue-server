class RemoveAssisteeAndAssistorFromFeedbacks < ActiveRecord::Migration[5.0]
  def change
    remove_column :feedbacks, :assistee_uid
    remove_column :feedbacks, :assistor_uid
  end
end
