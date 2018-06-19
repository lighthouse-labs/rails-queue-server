class Student < User

  has_many :day_feedbacks, foreign_key: :user_id
  has_many :feedbacks
  has_many :evaluations

  validates :unlocked_until_day, format: { with: TWO_DIGIT_WEEK_DAY_REGEX, allow_blank: true, message: 'Invalid Day Format' }, if: :use_double_digit_week?
  validates :unlocked_until_day, format: { with: DAY_REGEX, allow_blank: true, message: 'Invalid Day Format' }, unless: :use_double_digit_week?

  scope :in_active_cohort, -> { joins(:cohort).merge(Cohort.is_active) }
  scope :has_open_requests, -> {
    joins(:assistance_requests)
      .where(assistance_requests: { type: nil, canceled_at: nil, assistance_id: nil })
      .references(:assistance_requests)
  }
  scope :has_open_requests_in_location, ->(location) {
    joins(:assistance_requests)
      .where(assistance_requests: { type: nil, canceled_at: nil, assistance_id: nil, assistor_location_id: location })
      .references(:assistance_requests)
  }
  scope :remote, -> { joins(:cohort).where('users.location_id IS NOT NULL AND cohorts.location_id <> users.location_id') }

  def prospect?
    false
  end

  def rolled_in?(cohort)
    self.cohort == cohort && initial_cohort
  end

  def rolled_out?(cohort)
    cohort == initial_cohort
  end

  def remote?
    location && cohort && location != cohort.location
  end

  def active_student?
    cohort&.active?
  end

  def alumni?
    cohort&.finished?
  end

  def revert_to_prep
    update(type: nil, cohort: nil)
  end

  def curriculum_day
    cohort.curriculum_day.unlocked_until_day(location.timezone).to_s
  end

  def completed_code_review_requests
    assistance_requests.where(type: 'CodeReviewRequest').where.not(assistance_requests: { assistance_id: nil }).where(cohort_id: cohort_id).includes(:assistance)
  end

  def code_reviews_l_score
    completed_code_reviews = completed_code_review_requests
    if !completed_code_reviews.empty?
      # exclude nil values from ratings.
      ratings = completed_code_reviews.map(&:assistance).map { |e| e&.rating }.reject(&:nil?)
      ((ratings.inject(0) { |sum, rating| sum += rating }) / ratings.length.to_f).round(1)
    else
      'N/A'
    end
  end

  def mentor
    if mentor_id
      @teacher = Teacher.find(mentor_id)
      @teacher.full_name if @teacher.mentor?
    else
      'No Mentor'
    end
  end

end
