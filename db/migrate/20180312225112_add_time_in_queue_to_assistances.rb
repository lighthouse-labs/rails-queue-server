class AddTimeInQueueToAssistances < ActiveRecord::Migration[5.0]
  def up
    add_column :assistances, :secs_in_queue, :integer
    Assistance.has_assistance_request.includes(:assistance_request).find_each(batch_size: 100) do |assistance|
      assistance.secs_in_queue = assistance.start_at - assistance.assistance_request.created_at
      assistance.save
      puts "updated assistance id: #{assistance.id}"
    end
    remove_column :assistance_requests, :assistance_start_at
  end

  def down
    remove_column :assistances, :secs_in_queue
    add_column :assistance_requests, :assistance_start_at, :datetime
  end
end
