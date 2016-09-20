class AddCohortIdToTechInterviews < ActiveRecord::Migration[5.0]
  def change
    add_reference :tech_interviews, :cohort, foreign_key: true
  end
end
