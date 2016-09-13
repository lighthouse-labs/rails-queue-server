class AddMetricsToTechInterviews < ActiveRecord::Migration[5.0]
  def change
    add_column :tech_interviews, :articulation_score, :integer
    add_column :tech_interviews, :knowledge_score, :integer
  end
end
