class Quiz < ActiveRecord::Base

  QUESTIONS_PER_QUIZ = 5

  has_many :quiz_activities
  has_many :quiz_submissions, dependent: :nullify
  has_and_belongs_to_many :questions
  has_many :outcomes, through: :questions

  scope :active,   -> {
    where(id: Activity.active.where.not(quiz_id: nil).select(:quiz_id))
  }
  scope :prep,     -> {
    where(id: Activity.prep.active.where.not(quiz_id: nil).select(:quiz_id))
  }
  scope :bootcamp, -> {
    # Does 2 queries with an ugly id based array in the subquery, I know
    # That's because for some reason this more natural subquery approach won't work... bug in AR?
    #  `where(activity_id: Activity.bootcamp.whatever.whatever.select(:id))` (select instead of pluck)
    where(id: Activity.bootcamp.active.where.not(quiz_id: nil).pluck(:quiz_id))
  }

  def latest_submission_by(user)
    quiz_submissions.where(user_id: user.id).order(id: :desc).first
  end

  # validates :cohort, presence: true

  #validates :day, presence: true

  # validate do
  #   errors.add(:questions, "insufficient for a quiz; #{QUESTIONS_PER_QUIZ} needed") if questions.length < QUESTIONS_PER_QUIZ
  # end

  # before_validation on: :create do
  #   unless uuid
  #     self.uuid = SecureRandom.uuid
  #   end
  # end

end
