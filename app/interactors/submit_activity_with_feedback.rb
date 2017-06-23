class SubmitActivityWithFeedback
  include Interactor

  def call
    @activity = context.activity
    @user     = context.user
    @fields   = context.activity_submission_with_optional_feedback
    context.errors = []

    if @fields.time_spent.blank?
      context.errors << 'Tell us how much time you spent, please!'
      context.fail!
    end

    # Create a new submission if it is not a code eval
    unless @activity.evaluates_code?
      @activity_submission = context.activity_submission = @user.activity_submissions.new(
        user:       @user,
        activity:   @activity,
        time_spent: @fields.time_spent,
        note:       @fields.note,
        github_url: @fields.github_url
      )
    else
    # Update submission if it is a code eval
      @activity_submission = context.activity_submission = @user.activity_submissions.find_by({
        activity_id: @activity.id,
        finalized: true
      })
      @activity_submission.update({
        time_spent: @fields.time_spent,
        note: @fields.note,
        })
    end


    if @activity_submission.save
      if feedback?
        context.activity_feedback = @activity.activity_feedbacks.new(
          user: @user,
          rating: @fields.rating,
          detail: @fields.detail
        )
        context.activity_feedback.save
      end
    else
      context.errors += @activity_submission.errors.full_messages.dup
      context.fail!
    end
  end

  private

  def feedback?
    @fields.rating.present? || @fields.detail.present?
  end

end