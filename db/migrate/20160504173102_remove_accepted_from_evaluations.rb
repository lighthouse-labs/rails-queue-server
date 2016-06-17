class RemoveAcceptedFromEvaluations < ActiveRecord::Migration
  def change
    remove_column :evaluations, :accepted
  end
end
