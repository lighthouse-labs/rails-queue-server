class AddIncidesToAssistanceRequests < ActiveRecord::Migration[5.0]
  def change
    add_index :assistances, :assistor_id
    add_index :assistances, :assistee_id

    add_index :assistance_requests, :requestor_id
    add_index :assistance_requests, :assistor_id
    add_index :assistance_requests, :assistance_id
  end
end
