class CodeReviewRequest < AssistanceRequest

  before_create :set_activity_submission, if: :activity

  private

  def set_activity_submission
    self.activity_submission ||= self.requestor.activity_submissions.where(activity: self.activity).order(created_at: :desc).first
  end

end
