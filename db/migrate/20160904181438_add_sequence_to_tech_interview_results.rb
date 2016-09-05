class AddSequenceToTechInterviewResults < ActiveRecord::Migration[5.0]
  def change
    add_column :tech_interview_results, :sequence, :integer
  end
end
