class ActivitySubmission < ActiveRecord::Base

  # => For submissions on activities that have evaluates_code=true
  serialize :code_evaluation_results

  belongs_to :user
  belongs_to :activity

  has_one :code_review_request, dependent: :destroy

  before_create :set_finalized_for_code_evaluation

  #after_save :request_code_review
  after_create :create_feedback
  after_create :create_user_outcome_results
  after_destroy :handle_submission_destroy
  after_destroy :destroy_feedback

  default_value_for :completed_at, allows_nil: false do
    Time.now
  end

  # if there is code evaluation, allow multiple submissions
  validates :user_id, uniqueness: {
    scope: :activity_id,
    message: "only one submission per activity"
  }, unless: Proc.new {|activity_submission| activity_submission.activity.evaluates_code? }

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
    self.try(:code_review_request).try(:assistance)
  end

  private

  def set_finalized_for_code_evaluation
    if self.code_evaluation_results?
      # TODO handle more than just prep data
      results = formatted_code_evaluation_results
      self.finalized = results[:lint_results].zero? && results[:test_failures].zero?
    end

    # => Return true so it saves!
    true
  end

  def formatted_code_evaluation_results
    {
      lint_results: self.code_evaluation_results["lintResults"],
      test_failures: self.code_evaluation_results["testFailures"],
      test_passes: self.code_evaluation_results["testPasses"]
    }
  end

  def github_url_required?
    activity && activity.allow_submissions? && !activity.evaluates_code?
  end

  def request_code_review
    if self.activity.allow_submissions? && should_code_review? && self.code_review_request == nil
      self.create_code_review_request(requestor_id: self.user.id)
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

  def create_user_outcome_results
    self.activity.item_outcomes.each do |item_outcome|
      # TODO: change the way we calculate ratings
      if self.activity.create_outcome_results?
        self.user.outcome_results.create(
          outcome: item_outcome.outcome,
          source: item_outcome,
          rating: Prep.evaluate_rating(formatted_code_evaluation_results)
        )
      end
    end
  end

end
