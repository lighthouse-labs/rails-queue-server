class AssignAssistorLocationIdToAssistanceRequests < ActiveRecord::Migration[5.0]
  def up
    AssistanceRequest.order(id: :desc).find_each(batch_size: 200) do |ar|
      location_id = ar.requestor&.cohort&.location_id
      ar.update_column(:assistor_location_id, location_id)
    end
  end
  def down
    # nothing to do
  end
end
