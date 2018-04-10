class Project < Section

  has_many :evaluations
  has_many :item_outcomes, as: :item, dependent: :destroy
  has_many :outcomes, through: :item_outcomes

  default_scope -> { order(order: :asc) }

  validates :name, :description, presence: true

  scope :evaluated, -> { where(evaluated: true) }
  scope :core,      -> { where(stretch: [nil, false]) }
  scope :stretch,   -> { where(stretch: true) }

  before_validation :set_slug

  def complete?(user)
    activities.all? { |activity| user.completed_activity?(activity) }
  end

  def submitted?(student)
    last_evaluation(student).present?
  end

  def accepted?(student)
    if eval = last_evaluation(student)
      return eval.in_state?(:accepted)
    end
    false
  end

  def rejected?(student)
    if eval = last_evaluation(student)
      return eval.in_state?(:rejected)
    end
    false
  end

  def last_evaluation(student, cohort = nil)
    evaluations_for(student, cohort).first
  end

  def evaluations_for(student, cohort = nil)
    cohort ||= student.cohort
    evaluations.where(student: student, cohort: cohort).order(created_at: :desc)
  end

  def to_param
    slug
  end

  private

  def set_slug
    self.slug ||= name.gsub(/\s+/, "").downcase
  end

end
