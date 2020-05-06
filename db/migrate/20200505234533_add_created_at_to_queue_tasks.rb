class AddCreatedAtToQueueTasks < ActiveRecord::Migration[5.0]
  def change
    add_timestamps :queue_tasks, default: -> { 'now()' }, null: false
  end
end
