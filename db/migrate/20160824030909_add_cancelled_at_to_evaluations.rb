class AddCancelledAtToEvaluations < ActiveRecord::Migration
  def change
    add_column :evaluations, :cancelled_at, :datetime
  end
end
