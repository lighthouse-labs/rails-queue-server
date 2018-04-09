class AddAssistorLocationIdToAssistanceRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :assistance_requests, :assistor_location_id, :integer
    add_index :assistance_requests, :assistor_location_id
  end
end
