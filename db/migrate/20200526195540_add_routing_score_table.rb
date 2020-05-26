class AddRoutingScoreTable < ActiveRecord::Migration[5.0]
  def change
    create_table    :routing_scores do |t|
      t.string      :assistor_uid
      t.references  :assistance_request, foreign_key: true
      t.jsonb       :summary
      t.integer     :total
      t.timestamps
    end
    remove_column :queue_tasks, :routing_score
  end
end
