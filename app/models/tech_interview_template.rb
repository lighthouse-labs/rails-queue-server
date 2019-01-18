class TechInterviewTemplate < ApplicationRecord

  default_scope -> { order(week: :asc) }

  belongs_to :content_repository

  has_many :questions, { class_name: 'TechInterviewQuestion' }, -> { order(sequence: :asc) }
  has_many :tech_interviews

  validates :week, presence: true
  validates :uuid, presence: true

  scope :active, -> { where(archived: [false, nil]) }
  scope :due_for_cohort, ->(cohort) { where("tech_interview_templates.week <= ?", cohort.week) }

  def pending_interview_for(student)
    tech_interviews.interviewing(student).order(updated_at: :desc).queued.first
  end

  def interview_for(student)
    tech_interviews.interviewing(student).order(updated_at: :desc).first
  end

  def completed_interview_for(student, cohort = nil)
    tech_interviews.interviewing(student, cohort).order(updated_at: :desc).completed.first
  end

end
