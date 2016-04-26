class RemoveProjectIdFromItemOutcomes < ActiveRecord::Migration
  def change
    remove_column :item_outcomes, :project_id
  end
end
