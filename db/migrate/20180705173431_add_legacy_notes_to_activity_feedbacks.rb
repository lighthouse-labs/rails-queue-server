class AddLegacyNotesToActivityFeedbacks < ActiveRecord::Migration[5.0]
  def up
    new_fbs = 0
    ActivitySubmission.where.not(note: nil).find_each(batch_size: 100) do |submission|
      activity_feedback = ActivityFeedback.create(activity: submission.activity, 
                                                  user: submission.user, 
                                                  detail: submission.note, 
                                                  legacy_note: true, 
                                                  created_at: submission.created_at, 
                                                  updated_at: submission.updated_at)
      activity_feedback.save
      new_fbs += 1
    end
    p new_fbs
  end
  
  def down
  end
end
