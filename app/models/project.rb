class Project < Section

  has_many :evaluations
  has_many :item_outcomes, as: :item, dependent: :destroy
  has_many :outcomes, through: :item_outcomes

  default_scope -> { order(order: :asc) }

  validates :name, :description, presence: true

  before_validation :set_slug

  def complete?(user)
    self.activities.all? { |activity| user.completed_activity?(activity) }
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

  def last_evaluation(student)
    evaluations_for(student).first
  end

  def evaluations_for(student)
    evaluations.where(student: student, cohort: student.cohort).order(created_at: :desc)
  end

  private

  def set_slug
    self.slug ||= name.gsub(/\s+/, "").downcase
  end
end
