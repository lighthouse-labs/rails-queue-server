class UpdateFinalScore < ActiveRecord::Migration[5.0]
  def up
    change_column :evaluations, :final_score, :float
  end
  def down
    change_column :evaluations, :final_score, :integer
  end
end
