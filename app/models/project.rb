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

  def last_evaluation(student)
    evaluations_for(student).first
  end

  def evaluations_for(student)
    evaluations.where(student: student).order(created_at: :desc)
  end

  private

  def set_slug
    self.slug ||= name.gsub(/\s+/, "").downcase
  end
end
