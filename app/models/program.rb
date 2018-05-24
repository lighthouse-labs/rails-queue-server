class Program < ApplicationRecord

  has_many :cohorts
  has_many :recordings

  validates :name, presence: true
  validates :days_per_week, presence: true
  validate  :disable_queue_days_are_valid

  include DisableQueueDayValidators

  def part_time?
    days_per_week < 5
  end

  def curriculum_team_email
    'curriculum@team.com'
  end

end
