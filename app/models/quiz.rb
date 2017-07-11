class Quiz < ApplicationRecord

  QUESTIONS_PER_QUIZ = 5

  has_many :quiz_activities
  has_many :quiz_submissions, dependent: :nullify
  has_and_belongs_to_many :questions
  has_many :outcomes, through: :questions

  scope :active, -> {
    where(id: Activity.active.where.not(quiz_id: nil).select(:quiz_id))
  }
  scope :prep, -> {
    where(day: nil)
  }
  scope :bootcamp, -> {
    where.not(day: nil)
  }
  # Ideally this scope should be able to use the one above cleanly, but given the hack mentioned above, it's not easy.
  scope :until_day, ->(day) {
    where(id: Activity.bootcamp.active.where.not(quiz_id: nil).until_day(day).pluck(:quiz_id))
  }

  def submissions_by(user)
    chain = quiz_submissions.where(user_id: user.id).order(id: :desc)
    chain = chain.where(cohort_id: user.cohort_id) if user.cohort_id? && bootcamp?
    chain
  end

  def latest_submission_by(user)
    submissions_by(user).first
  end

  def prep?
    !bootcamp?
  end

  def bootcamp?
    day?
  end

  # validates :cohort, presence: true

  # validates :day, presence: true

  # validate do
  #   errors.add(:questions, "insufficient for a quiz; #{QUESTIONS_PER_QUIZ} needed") if questions.length < QUESTIONS_PER_QUIZ
  # end

  # before_validation on: :create do
  #   unless uuid
  #     self.uuid = SecureRandom.uuid
  #   end
  # end

end
