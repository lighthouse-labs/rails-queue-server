class AddAssistanceStartTimeDataToAssistanceRequests < ActiveRecord::Migration[5.0]
  def up
    puts "starting migration we have#{AssistanceRequest.all.count} records to handle"
    AssistanceRequest.find_each(batch_size: 100) do |ar|
      puts "starting batch with id: #{ar.id}"
      if ar.assistance_id.present?
        assistance = Assistance.find(ar.assistance_id)
        ar.assistance_start_at = assistance.start_at if assistance
        ar.save
      end
    end
    remove_column :assistance_requests, :assistance_end_at
  end
  def down
    AssistanceRequest.update_all(assistance_start_at: nil)
    add_column :assistance_requests, :assistance_end_at, :datetime
  end
end
