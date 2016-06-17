class AddDefaultValueToEvaluationStatus < ActiveRecord::Migration
  def change
    change_column :evaluations, :status, :string, default: 'pending'
  end
end
