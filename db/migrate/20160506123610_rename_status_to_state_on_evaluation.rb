class RenameStatusToStateOnEvaluation < ActiveRecord::Migration
  def change
    rename_column :evaluations, :status, :state
  end
end
