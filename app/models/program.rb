class Program < ApplicationRecord

  has_many :cohorts
  has_many :recordings

  validates :name, presence: true
  validate  :disable_queue_days_are_valid

  include DisableQueueDayValidators

end
