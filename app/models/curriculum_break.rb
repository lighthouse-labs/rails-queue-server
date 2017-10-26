class CurriculumBreak < ApplicationRecord

  belongs_to :cohort

  validates :reason, :starts_on, :num_weeks, presence: true

  #Validation Required: Starts on Mondays, They do not overlap

end
