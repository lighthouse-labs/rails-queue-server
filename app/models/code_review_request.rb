class CodeReviewRequest < AssistanceRequest

  before_create :set_activity_submission, if: :activity

  private

  def set_activity_submission
    self.activity_submission ||= requestor.activity_submissions.where(activity: activity).order(created_at: :desc).first
  end

end
