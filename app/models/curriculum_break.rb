class CurriculumBreak < ApplicationRecord

  belongs_to :cohort
  scope :for_cohort, -> (cohort) { where cohort_id: cohort.id }

  #Validation Required: Starts on Mondays, They do not overlap

end
