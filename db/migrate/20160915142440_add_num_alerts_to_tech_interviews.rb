class AddNumAlertsToTechInterviews < ActiveRecord::Migration[5.0]
  def change
    add_column :tech_interviews, :num_alerts, :integer, default: 0
  end
end
