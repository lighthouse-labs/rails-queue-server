class RemoveColumnFromAssistances < ActiveRecord::Migration[5.0]
  def change
    remove_column :assistance_requests, :assistance_start_at
  end
end
