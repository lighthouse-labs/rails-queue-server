class CohortAddDeletedAtColumn < ActiveRecord::Migration[5.0]
  def change
      add_column :cohorts, :deleted_at, :datetime
      add_index :cohorts, :deleted_at
  end
end
