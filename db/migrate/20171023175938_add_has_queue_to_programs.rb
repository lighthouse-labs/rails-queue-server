class AddHasQueueToPrograms < ActiveRecord::Migration[5.0]
  def change
    add_column :programs, :has_queue, :boolean
  end
end
