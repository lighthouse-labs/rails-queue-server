class Evaluation < ActiveRecord::Base

  belongs_to :project

  belongs_to :student

  belongs_to :teacher

end
