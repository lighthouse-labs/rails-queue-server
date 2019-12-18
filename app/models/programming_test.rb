class ProgrammingTest < ApplicationRecord

  # autosave is important becaused on how these are created
  # https://github.com/lighthouse-labs/compass/pull/932#issuecomment-551342225
  has_many :test_activities, dependent: :nullify, autosave: false

  validates :exam_code, presence: true
  validates :uuid, presence: true

  scope :active, -> {
    joins(:test_activities)
      .where(activities: { archived: [false, nil] })
      .order('activities.day')
  }

end
