class TechInterviewQuestion < ApplicationRecord

  belongs_to :tech_interview_template
  belongs_to :outcome

  scope :active, -> { where(archived: false) }
  scope :sequential, ->  { order(:sequence) }

  validates :tech_interview_template, presence: true
  validates :uuid, presence: true
  validates :question, presence: true
  validates :answer, presence: true

end
