class AddQueueTasksTable < ActiveRecord::Migration[5.0]
  def change
    create_table    :queue_tasks do |t|
      t.references  :assistance_request, foreign_key: true
      t.references  :user, foreign_key: true
      t.integer :sequence
      t.index :sequence, unique: true
    end
  end
end
