class AddLastAlertedAtToTechInterviews < ActiveRecord::Migration[5.0]
  def change
    add_column :tech_interviews, :last_alerted_at, :datetime
  end
end
