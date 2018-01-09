class AddDisableQueueDays < ActiveRecord::Migration[5.0]
  def change
    add_column :programs, :disable_queue_days, :text, array: true, default: [], null: false
    add_column :cohorts, :disable_queue_days, :text, array: true, default: [], null: false
  end
end
