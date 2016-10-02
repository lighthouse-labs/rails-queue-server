class Student < User

  has_many :day_feedbacks, foreign_key: :user_id
  has_many :feedbacks

  scope :in_active_cohort, -> { joins(:cohort).merge(Cohort.is_active) }
  scope :has_open_requests, -> {
    joins(:assistance_requests).
    where(assistance_requests: {type: nil, canceled_at: nil, assistance_id: nil}).
    references(:assistance_requests)
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

  def enrolled_and_prepping?
    cohort && cohort.upcoming?
  end

  def active_student?
    cohort && cohort.active?
  end

  def alumni?
    cohort && cohort.finished?
  end

  def completed_code_review_requests
    assistance_requests.where(type: 'CodeReviewRequest').where.not(assistance_requests: {assistance_id: nil}).where(cohort_id: self.cohort_id).includes(:assistance)
  end

  def code_reviews_l_score
    completed_code_reviews = completed_code_review_requests
    if completed_code_reviews.length > 0
      # exclude nil values from ratings.
      ratings = completed_code_reviews.map(&:assistance).map { |e| e.rating if e }.reject(&:nil?)
      ((ratings.inject(0){|sum, rating| sum+= rating})/ratings.length.to_f).round(1)
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
