class CreateQueueTasks < ActiveRecord::Migration[5.0]
  def change
    create_table    :queue_tasks do |t|
      t.string      :assistor_uid
      t.references  :assistance_request, foreign_key: true
      t.jsonb       :routing_score
      t.timestamps
    end
  end
end
