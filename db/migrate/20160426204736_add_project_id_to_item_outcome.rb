class AddProjectIdToItemOutcome < ActiveRecord::Migration
  def change
    add_column :item_outcomes, :project_id, :integer
  end
end
