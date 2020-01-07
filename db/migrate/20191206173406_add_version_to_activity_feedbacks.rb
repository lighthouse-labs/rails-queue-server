class AddVersionToActivityFeedbacks < ActiveRecord::Migration[5.0]
  def change
    add_column :activity_feedbacks, :version, :integer
  end
end
