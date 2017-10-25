class CurriculumBreak < ApplicationRecord

  belongs_to :cohort

  #Validation Required: Starts on Mondays, They do not overlap

end
