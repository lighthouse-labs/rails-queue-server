class AddResubmissionToEvaluations < ActiveRecord::Migration[5.0]
  def change
    add_column :evaluations, :resubmission, :boolean
  end
end
