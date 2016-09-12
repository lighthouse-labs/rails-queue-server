class TechInterview < ApplicationRecord

  belongs_to :tech_interview_template
  belongs_to :interviewee, class_name: 'User'
  belongs_to :interviewer, class_name: 'User'
  # since we dont have an enrollment record, this handles rollover (multi-cohort) students
  belongs_to :cohort

  has_many :results, { class_name: 'TechInterviewResult', dependent: :destroy }

  accepts_nested_attributes_for :results, allow_destroy: false

  scope :interviewed_by, -> (interviewer) { where(interviewer: interviewer) }
  scope :interviewing,   -> (interviewee) { where(interviewee: interviewee, cohort: interviewee.cohort) }
  scope :completed,      -> { where.not(completed_at: nil) }
  scope :queued,         -> { where(started_at: nil) }
  scope :active,         -> { where(completed_at: nil) }
  scope :in_progress,    -> { where.not(started_at: nil).where(completed_at: nil) }
  scope :for_cohort,     -> (cohort) { where(cohort: cohort) }
  scope :for_locations,  -> (locations) {
    if locations.is_a?(Array) && locations.length > 0
      includes(cohort: :location).
      where(locations: { name: locations }).
      references(:cohort, :location)
    end
  }

  validates :tech_interview_template, presence: true
  validates :interviewee, presence: true

  before_create :set_cohort

  def in_progress?
    started? && !completed?
  end

  def week
    tech_interview_template.week
  end

  def started?
    started_at?
  end

  def queued?
    !started?
  end

  def completed?
    completed_at?
  end

  # in minutes
  def duration
    (completed_at - started_at).to_i
  end

  # in minutes
  def time_in_queue
    ((started_at || Time.current) - created_at).to_i
  end

  private

  def set_cohort
    # expect to always an interviewee and for them to have a cohort
    self.cohort = self.interviewee.cohort
  end

end
