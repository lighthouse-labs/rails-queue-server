class Program < ApplicationRecord

  has_many :cohorts
  has_many :content_repositories

  validates :name, presence: true
  validates :days_per_week, presence: true
  validate  :disable_queue_days_are_valid

  include DisableQueueDayValidators

  def part_time?
    days_per_week < 5
  end

end
