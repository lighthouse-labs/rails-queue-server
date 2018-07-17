class AddLegacyNotesToActivityFeedbacks < ActiveRecord::Migration[5.0]
  def up
    new_feedbacks_count = 0
    ActivitySubmission.where.not(note: nil).find_each(batch_size: 100) do |submission|
      activity_feedback = ActivityFeedback.create(activity: submission.activity, 
                                                  user: submission.user, 
                                                  detail: submission.note, 
                                                  legacy_note: true, 
                                                  created_at: submission.created_at, 
                                                  updated_at: submission.updated_at)
      activity_feedback.save
      new_feedbacks_count += 1
    end
    say 'There were ' + new_feedbacks_count.to_s + ' legacy feedbacks created.'
  end

end
