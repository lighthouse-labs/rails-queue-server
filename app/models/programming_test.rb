class ProgrammingTest < ApplicationRecord
  has_many :test_activities

  scope :active, -> { 
    includes(:test_activities)
      .where(activities: { archived: [false, nil] })
      .order('activities.day')
    }
end
