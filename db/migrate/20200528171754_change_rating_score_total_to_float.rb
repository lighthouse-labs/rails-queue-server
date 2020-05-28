class ChangeRatingScoreTotalToFloat < ActiveRecord::Migration[5.0]
  def change
    change_column :routing_scores, :total, :float
  end
end
