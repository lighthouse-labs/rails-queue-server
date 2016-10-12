class AddCohortIdToAssistanceRequests < ActiveRecord::Migration[5.0]
  def up
    add_column :assistance_requests, :cohort_id, :integer
    add_index :assistance_requests, :cohort_id

    puts 'Updating assistance requests with cohort_id'
    AssistanceRequest.find_each(batch_size: 100) do |request|
      if request.requestor.try :cohort_id?
        request.update_columns(cohort_id: request.requestor.cohort_id)
        print '.'; STDOUT.flush
      end
    end
    puts 'Done'
  end
  def down
    remove_column :assistance_requests, :cohort_id
  end
end
