class AddCompletedAtToEvaluation < ActiveRecord::Migration
  def change
    add_column :evaluations, :completed_at, :datetime
  end
end
