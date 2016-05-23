class AssistanceRequestSubmissionToActivity < ActiveRecord::Migration

  def up
    requests = AssistanceRequest.where.not(activity_submission_id: nil).where(activity_id: nil)
    puts "Updating #{requests.count} requests: "
    requests.find_each(batch_size: 500) do |ar|
      # submission is needed for activity_id
      if sub = ar.activity_submission
        # use update_all so as to not trigger .save so as to not do validation nor modify updated_at field
        AssistanceRequest.where(id: ar.id).update_all(activity_id: sub.activity_id)
        print '.'; STDOUT.flush
      else
        print "[#{ar.id}]"; STDOUT.flush
      end
    end
    puts "\nDONE!"
  end

  def down
    AssistanceRequest.update_all(activity_id: nil)
  end

end
