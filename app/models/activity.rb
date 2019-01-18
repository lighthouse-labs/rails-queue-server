class Activity < ApplicationRecord

  belongs_to :section
  # optional. Means content stored on server
  belongs_to :content_repository

  has_many :activity_submissions, -> { order(:user_id) }
  has_many :assistances, -> { order(:user_id) }
  has_many :assistance_requests
  has_many :messages, -> { order(created_at: :desc) }, class_name: 'ActivityMessage'
  has_many :recordings, -> { order(created_at: :desc) }
  has_many :lectures, -> { order(created_at: :desc) }
  has_many :feedbacks, as: :feedbackable
  has_many :activity_feedbacks, dependent: :destroy # new, to replace the above

  has_many :item_outcomes, as: :item, dependent: :destroy
  has_many :outcomes, through: :item_outcomes
  has_many :skills, through: :outcomes
  has_many :outcome_results, as: :source

  include PgSearch
  pg_search_scope :by_keywords,
                  against:            [:name, :day, :type, :instructions],
                  associated_against: {
                    section: [:name, :type],
                    skills:  :name
                  },
                  using:              {
                    tsearch: {
                      dictionary: "english",
                      any_word:   true,
                      prefix:     true
                    }
                  }

  validates :name, presence: true, length: { maximum: 56 }
  validates :duration, numericality: { only_integer: true, allow_blank: true }
  validates :start_time, numericality: { only_integer: true, allow_blank: true }
  validates :sequence, numericality: { only_integer: true }
  validates :day, format: { with: DAY_REGEX, allow_blank: true }
  validates :uuid, presence: true, uniqueness: true

  scope :chronological, -> { order("activities.sequence ASC, activities.id ASC") }
  scope :reverse_chronological_for_day, -> { order("activities.day DESC, activities.sequence DESC") }
  scope :chronological_for_project, -> { includes(:section).references(:section).order("sections.order ASC, activities.day ASC, activities.sequence ASC, activities.id ASC") }
  scope :for_day,   ->(day) { where(day: day.to_s) }
  scope :for_week,  ->(day) { where("activities.day BETWEEN ? AND ?", day.start_of_week.to_s, day.end_of_week.to_s) }
  scope :until_day, ->(day) { where("activities.day <= ?", day.to_s) }
  scope :search,    ->(query) { where("lower(name) LIKE :query or lower(day) LIKE :query", query: "%#{query.downcase}%") }
  scope :active,    -> { where(archived: [false, nil]) }
  scope :archived,  -> { where(archived: true) }

  scope :assistance_worthy, -> { where.not(type: %w[LecturePlan Breakout PinnedNote]) }

  scope :countable_as_submission, -> { where.not(type: %w[QuizActivity PinnedNote LecturePlan Breakout Test]) }

  scope :core,    -> { where(stretch: [nil, false]) }
  scope :stretch, -> { where(stretch: true) }
  scope :milestone, -> { where(milestone: true) }

  scope :prep, -> {
    joins(:section).where(sections: { type: 'Prep' })
  }

  scope :teacher, -> {
    joins(:section).where(sections: { type: 'TeacherSection' })
  }

  scope :bootcamp, -> {
    where.not(day: nil)
  }

  scope :past_due_for_cohort, ->(cohort) { where("day <= ?", CurriculumDay.new(Time.zone.yesterday, cohort).to_s) }

  after_update :add_revision_to_gist

  # to avoid callback on .update via instruction download
  attr_accessor :fetching_remote_content

  def active?
    !archived?
  end

  def completable?
    true
  end

  def can_mark_completed?
    true
  end

  # Given the start_time and duration, return the end_time
  def end_time
    hours = start_time / 100
    minutes = start_time % 100
    duration_hours = duration / 60
    duration_minutes = duration % 60

    if duration_minutes + minutes >= 60
      hours += 1
      minutes = (duration_minutes + minutes) % 60
      duration_minutes = 0
    end

    (hours + duration_hours) * 100 + (minutes + duration_minutes)
  end

  def next
    return @next if @next

    activities = Activity.active.chronological.where('activities.sequence > ?', sequence)

    if prep? || teachers_only?
      activities = activities.where(section: section)
    elsif day?
      activities = activities.where(day: day)
    end

    @next = activities.first
  end

  def previous
    return @prev if @prev
    activities = Activity.active.chronological.where('activities.sequence < ?', sequence)

    if prep? || teachers_only?
      activities = activities.where(section: section)
    elsif day?
      activities = activities.where(day: day)
    end

    @prev = activities.last
  end

  def duration_range
    [duration, average_time_spent || duration].compact.uniq.sort
  end

  def approx_duration
    range = duration_range
    if range.many?
      ((range[0].to_f + range[1].to_f) / 2.0).round(0)
    else 
      range[0]
    end
  end

  # if it has it, display it
  # overwritten by some subclasses like Test, LecturePlan, Breakout, etc
  def display_duration?
    duration? || average_time_spent?
  end

  def display_vague_duration?
    false
  end

  def allow_feedback?
    true
  end

  def has_rated_feedback?
    activity_feedbacks.rated.any?
  end

  def repo_full_name
    content_repository.try :full_name
  end

  def prep?
    section&.is_a?(Prep)
  end

  def project?
    section&.is_a?(Project)
  end

  def bootcamp?
    !prep? && day?
  end

  def teachers_only?
    section&.is_a?(TeacherSection)
  end

  def has_lectures?
    false
  end

  # Also could be overwritten by sub classes
  def create_outcome_results?
    evaluates_code?
  end

  protected

  def add_revision_to_gist
    if changes.any?
      # For now don't bother with this, content already mostly in repo - KV
      # puts "DOING REVISION GIST!"
      # g = ActivityRevision.new(self)
      # g.commit
    end
  end

  def gist_id
    gist_url.split('/').last
  end

end
