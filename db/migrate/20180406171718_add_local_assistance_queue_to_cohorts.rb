class AddLocalAssistanceQueueToCohorts < ActiveRecord::Migration[5.0]
  def change
    add_column :cohorts, :local_assistance_queue, :boolean
  end
end
