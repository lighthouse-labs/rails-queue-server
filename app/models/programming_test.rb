class ProgrammingTest < ApplicationRecord

  has_many :test_activities, dependent: :nullify

  validates :exam_code, presence: true
  validates :uuid, presence: true

  scope :active, -> {
    includes(:test_activities)
      .where(activities: { archived: [false, nil] })
      .order('activities.day')
  }

end
