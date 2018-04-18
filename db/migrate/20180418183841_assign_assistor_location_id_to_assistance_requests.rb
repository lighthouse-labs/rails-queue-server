class AssignAssistorLocationIdToAssistanceRequests < ActiveRecord::Migration[5.0]
  def up
    AssistanceRequest.find_each(batch_size: 200) do |ar|
      location = ar.requestor&.cohort&.location
      ar.update_column(:assistor_location_id, location&.id)
    end
  end
  def down
    # nothing to do
  end
end
