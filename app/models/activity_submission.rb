class ActivitySubmission < ActiveRecord::Base

  belongs_to :user
  belongs_to :activity

  has_one :code_review_request, dependent: :destroy

  #after_save :request_code_review
  after_create :create_feedback
  after_destroy :handle_submission_destroy
  after_destroy :destroy_feedback

  default_value_for :completed_at, allows_nil: false do
    Time.now
  end

  validates :user_id, uniqueness: { scope: :activity_id,
    message: "only one submission per activity" }

  validates :github_url,
    presence: :true,
    format: { with: URI::regexp(%w(http https)), message: "must be a valid format" },
    if: :github_url_required?

  scope :with_github_url, -> {
    includes(:activity).
    where(activities: {allow_submissions: true}).
    references(:activity)
  }

  scope :not_code_reviewed, -> {
    where(code_review_request: nil)
  }

  def code_reviewed?
    # NOTE when I transposed this relationship the :code_review_request was disassociated
    # It may make sense to keep the relationship so I have left it in place.
    # Really we have some bad normalization because of this, but I consider
    # it transitional at this point.
    CodeReviewRequest.where(activity_id: self.activity_id, requestor_id: self.user_id).where.not(assistance_id: nil).joins(:assistance).references(:assistance).where.not(assistances: { end_at: nil }).any?
  end

  private

  def github_url_required?
    activity && activity.allow_submissions?
  end

  def request_code_review
    if self.activity.allow_submissions? && should_code_review? && self.code_review_request == nil
      self.create_code_review_request(requestor_id: self.user.id, activity: self.activity)
    end
  end

  def should_code_review?
    return false if user.code_review_percent.nil? || activity.code_review_percent.nil?
    student_probablitiy = user.code_review_percent / 100.0
    activity_probability = activity.code_review_percent / 100.0
    student_probablitiy * activity_probability >= rand
  end

  def create_feedback
    self.activity.feedbacks.create(student: self.user) if self.user.is_a?(Student) && self.activity.allow_feedback?
  end

  def destroy_feedback
    if self.activity.allow_feedback?
       @feedback = self.activity.feedbacks.find_by(student: self.user)
       @feedback.destroy if @feedback
    end
  end

  def handle_submission_destroy
    ActionCable.server.broadcast "assistance", {
      type: "CancelAssistanceRequest",
      object: AssistanceRequestSerializer.new(self.code_review_request, root: false).as_json
    }
  end

end
