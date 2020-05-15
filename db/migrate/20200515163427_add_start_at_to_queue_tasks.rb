class AddStartAtToQueueTasks < ActiveRecord::Migration[5.0]
  def change
    add_column :queue_tasks, :start_at, :datetime
  end
end
