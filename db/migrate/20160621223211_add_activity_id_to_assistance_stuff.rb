class AddActivityIdToAssistanceStuff < ActiveRecord::Migration
  def change
    # add_column :assistance_requests, :activity_id, :integer
    add_column :assistances, :activity_id, :integer

    add_index :assistance_requests, :activity_id
    add_index :assistances, :activity_id
  end
end
