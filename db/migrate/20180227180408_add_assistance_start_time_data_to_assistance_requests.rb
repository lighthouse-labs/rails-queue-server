class AddAssistanceStartTimeDataToAssistanceRequests < ActiveRecord::Migration[5.0]
  def up
    AssistanceRequest.find_each(batch_size: 100) do |ar|
      if ar.assistance_id.present?
        ar.assistance_start_at = Assistance.find(ar.assistance_id).start_at
        ar.save!
      end
    end
  end
  def down
    AssistanceRequest.update_all(assistance_start_at: nil)
  end
end
