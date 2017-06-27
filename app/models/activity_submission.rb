class ActivitySubmission < ApplicationRecord

  # => For submissions on activities that have evaluates_code=true
  # serialize :code_evaluation_results

  belongs_to :user
  belongs_to :activity
  belongs_to :cohort # substitute for lack of enrollment record - KV

  has_one :code_review_request, dependent: :destroy

  # before_create :set_finalized_for_project_activity_submissions
  before_create :set_finalized_for_code_evaluation
  before_create :set_cohort

  after_create :create_user_outcome_results
  after_destroy :handle_submission_destroy

  default_value_for :completed_at, allows_nil: false do
    Time.now
  end

  # if there is code evaluation, allow multiple submissions
  validates :user_id, uniqueness: {
    scope:   [:activity_id, :cohort_id],
    message: "only one submission per activity per cohort"
  }, unless: proc { |activity_submission| activity_submission.activity.evaluates_code? }

  validates :github_url,
            presence: :true,
            format:   { with: URI.regexp(%w[http https]), message: "must be a valid format" },
            if:       :github_url_required?

  scope :with_github_url, -> {
    includes(:activity)
    .where(activities: { allow_submissions: true })
    .references(:activity)
  }

  scope :not_code_reviewed, -> {
    where(code_review_request: nil)
  }

  scope :proper, -> {
    joins(:activity).where("activities.type NOT IN ('QuizActivity', 'PinnedNote', 'Lecture', 'Breakout', 'Test') AND (activities.evaluates_code = false OR activities.evaluates_code IS NULL OR activity_submissions.finalized = true)")
  }

  scope :prep, -> {
    where(activity_id: Activity.prep.select(:id))
  }

  scope :core, -> {
    joins(:activity).where(activities: { stretch: [nil, false] })
  }
  scope :stretch, -> {
    joins(:activity).where(activities: { stretch: true })
  }

  scope :for_day, ->(day) {
    joins(:activity).where("activities.day = ?", day.to_s)
  }
  scope :until_day, ->(day) {
    joins(:activity).where("activities.day <= ?", day.to_s)
  }

  scope :reasonable_time_spent_stats, -> {
    where.not(time_spent: nil).where(time_spent: [2..499])
  }

  scope :bootcamp, -> {
    # Does 2 queries with an ugly id based array in the subquery, I know
    # That's because for some reason this more natural subquery approach won't work... bug in AR?
    #  `where(activity_id: Activity.bootcamp.select(:id))`
    where(activity_id: Activity.bootcamp.pluck(:id))
  }

  def eval_results
    if code_evaluation_results?
      YAML.safe_load code_evaluation_results.sub('--- !ruby/hash:ActionController::Parameters', '---')
    end
  end

  def code_reviewed?
    # NOTE when I transposed this relationship the :code_review_request was disassociated
    # It may make sense to keep the relationship so I have left it in place.
    # Really we have some bad normalization because of this, but I consider
    # it transitional at this point.
    CodeReviewRequest.where(activity_id: activity_id, requestor_id: user_id).where.not(assistance_id: nil).joins(:assistance).references(:assistance).where.not(assistances: { end_at: nil }).any?
  end

  private

  def set_finalized_for_code_evaluation
    if code_evaluation_results?
      # TODO: handle more than just prep data
      results = formatted_code_evaluation_results
      self.finalized = results[:lint_results].zero? && results[:test_failures].zero?
    end

    # => Return true so it saves!
    true
  end

  def set_cohort
    if activity.try(:bootcamp?) && user.try(:cohort_id)
      self.cohort_id = user.cohort_id
    end
  end

  def formatted_code_evaluation_results
    {
      lint_results:  eval_results["lintResults"],
      test_failures: eval_results["testFailures"],
      test_passes:   eval_results["testPasses"]
    }
  end

  def github_url_required?
    activity && activity.allow_submissions? && !activity.evaluates_code?
  end

  def should_code_review?
    return false if user.code_review_percent.nil? || activity.code_review_percent.nil?
    student_probablitiy = user.code_review_percent / 100.0
    activity_probability = activity.code_review_percent / 100.0
    student_probablitiy * activity_probability >= rand
  end  def handle_submission_destroy
    ActionCable.server.broadcast "assistance",       type:   "CancelAssistanceRequest",
      object: AssistanceRequestSerializer.new(code_review_request, root: false).as_json
  end

  def create_user_outcome_results
    activity.item_outcomes.each do |item_outcome|
      # TODO: change the way we calculate ratings
      next unless self.activity.create_outcome_results?
      user.outcome_results.create(
        outcome: item_outcome.outcome,
        source:  item_outcome,
        rating:  Prep.evaluate_rating(formatted_code_evaluation_results)
      )
    end
  end

end
