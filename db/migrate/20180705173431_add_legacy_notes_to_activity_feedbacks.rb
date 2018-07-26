class AddLegacyNotesToActivityFeedbacks < ActiveRecord::Migration[5.0]

  # Example output from production db backup on local - KV
  # If we skip based on 'github.com/' being in the note, the final output is:
  # -- There were 11755 legacy feedbacks created.
  # -- There were 556 legacy feedbacks skipped.
  # If we don't skip 'github.com/' being in the note, the final output is:
  # -- There were 12258 legacy feedbacks created.
  # -- There were 53 legacy feedbacks skipped.

  def up
    skipped_feedbacks_count = 0
    new_feedbacks_count = 0
    ActivitySubmission.where.not(note: [nil, '']).find_each(batch_size: 100) do |submission|
      if skip?(submission)
        say "Skipping #{submission.id}"
        skipped_feedbacks_count += 1
      else
        activity_feedback = ActivityFeedback.new(activity: submission.activity,
                                                    user: submission.user,
                                                    detail: submission.note,
                                                    legacy_note: true,
                                                    created_at: submission.created_at,
                                                    updated_at: submission.updated_at)
        # it should always save, but just in case
        new_feedbacks_count += 1 if activity_feedback.save
      end
    end
    say "There were #{new_feedbacks_count.to_s} legacy feedbacks created."
    say "There were #{skipped_feedbacks_count.to_s} legacy feedbacks skipped."
  end

  def down
    ActivityFeedback.where(legacy_note: true).delete_all
  end

  private

  # Defend against blank user: For some reason production data had submission's not tied to a user record (deleted?).
  #
  def skip?(submission)
    submission.note.blank? || submission.user.blank? || submission.note.include?('github.com/')
  end

end
