class AddStartedAtToEvaluation < ActiveRecord::Migration
  def change
    add_column :evaluations, :started_at, :datetime
  end
end
