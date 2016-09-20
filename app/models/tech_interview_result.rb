class TechInterviewResult < ApplicationRecord

  default_scope -> { order(sequence: :asc) }

  belongs_to :tech_interview
  belongs_to :tech_interview_question

  validates :tech_interview, presence: true
  validates :question,       presence: true
  validates :score, inclusion: { in: [1,2,3,4] }, allow_blank: true

  def skipped?
    score.blank?
  end

end
