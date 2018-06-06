class Lecture < ApplicationRecord

  default_scope { order(created_at: :desc) }

  belongs_to :presenter, class_name: User
  belongs_to :cohort
  belongs_to :activity

  scope :for_cohort, ->(cohort) { where(cohort_id: cohort.id) }

  validates :activity, presence: true
  validates :cohort, presence: true

  validates :subject, presence: true, length: { maximum: 100 }
  validates :day, presence: true, format: { with: DAY_REGEX, allow_blank: true }

  validates :body, presence: true

  def manageable_by?(user)
    user.admin? || (user == self.presenter)
  end

end
