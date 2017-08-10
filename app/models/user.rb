class User < ApplicationRecord

  include PgSearch
  pg_search_scope :by_keywords,
                  against: [:first_name, :last_name, :email, :phone_number, :github_username, :slack, :bio, :quirky_fact, :specialties],
                  using:   {
                    tsearch: {
                      dictionary: "english",
                      any_word:   true,
                      prefix:     true
                    }
                  }

  mount_uploader :custom_avatar, CustomAvatarUploader

  belongs_to :cohort
  belongs_to :initial_cohort, class_name: 'Cohort' # rollover student have this set
  belongs_to :location

  has_many :recordings, foreign_key: :presenter_id

  has_many :assistance_requests, foreign_key: :requestor_id
  has_many :assistances, foreign_key: :assistee_id

  has_many :activity_submissions
  has_many :activity_feedbacks, dependent: :destroy
  has_many :submitted_activities, through: :activity_submissions, source: :activity
  has_many :outcome_results
  has_many :evaluations
  has_many :quiz_submissions

  has_many :tech_interviews, foreign_key: 'interviewee_id'
  has_many :performed_tech_interviews, foreign_key: 'interviewer_id', class_name: 'TechInterviewResult'

  scope :order_by_last_assisted_at, -> {
    order("last_assisted_at ASC NULLS FIRST")
  }
  scope :cohort_in_locations, ->(locations) {
    if locations.is_a?(Array) && !locations.empty?
      includes(cohort: :location)
        .where(locations: { name: locations })
        .references(:cohort, :location)
    end
  }
  scope :active, -> {
    where(deactivated_at: nil, completed_registration: true)
  }
  scope :deactivated, -> {
    where.not(deactivated_at: nil)
  }
  scope :completed_activity, ->(activity) {
    if activity.is_a?(QuizActivity)
      # For quiz activities, we don't have activity submissions, and quiz_submissions are used to determine completion instead
      joins(:quiz_submissions).where(quiz_submissions: { initial: true, quiz_id: activity.quiz_id })
    else
      q = joins(:activity_submissions).where(activity_submissions: { activity: activity })
      q = q.where(activity_submissions: { finalized: true }) if activity.evaluates_code?
      q
    end
  }

  validates :uid,             presence: true
  validates :token,           presence: true
  validates :first_name,      presence: true
  validates :last_name,       presence: true
  validates :phone_number,    presence: true
  validates :email,           email: true
  validates :location_id,     presence: true
  validates :github_username, presence: true

  def prospect?
    true
  end

  def initials
    "#{first_name.first.upcase}#{last_name.first.upcase}"
  end

  def enrolled_and_prepping?
    false
  end

  def active_student?
    false
  end

  def alumni?
    false
  end

  def deactivate!
    update! deactivated_at: Time.now
  end

  def reactivate!
    update! deactivated_at: nil
  end

  def deactivated?
    deactivated_at?
  end

  def active?
    !deactivated? && completed_registration?
  end

  def unlocked?(day)
    # for special students we can unlock future material using `unlocked_until_day` field
    (unlocked_until_day? && day.to_s <= unlocked_until_day) || day.unlocked?
  end

  def can_access_day?(day)
    unlocked? CurriculumDay.new(day, cohort)
  end

  def being_assisted?
    assistance_requests.where(type: nil).in_progress_requests.exists?
  end

  def position_in_queue
    assistance_requests.where(type: nil).open_requests.newest_requests_first.first.try(:position_in_queue)
  end

  def current_assistor
    assistance_requests.where(type: nil).in_progress_requests.newest_requests_first.first.try(:assistance).try(:assistor)
  end

  def waiting_for_assistance?
    assistance_requests.where(type: nil).open_requests.exists?
  end

  def completion_records_for(activity)
    if activity.evaluates_code?
      chain = activity_submissions.where(finalized: true, activity: activity)
      chain = chain.where(cohort_id: cohort_id) if activity.bootcamp? && cohort_id?
      chain
    elsif activity.is_a?(QuizActivity)
      activity.quiz.submissions_by(self)
    elsif activity.bootcamp? && cohort_id?
      activity_submissions.where(cohort_id: cohort_id).where(activity_id: activity.id)
    else
      activity_submissions.where(activity: activity)
    end
  end

  def completed_activity?(activity)
    completion_records_for(activity).present?
  end

  def completed_at(activity)
    completion_records_for(activity).first.try :completed_at
  end

  def github_url(activity)
    completion_records_for(activity).first.try(:github_url) if completed_activity?(activity)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def incomplete_activities
    if cohort.started? && !cohort.on_curriculum_day?('w1d1')
      Activity.active.countable_as_submission.where.not(id: activity_submissions.select(:activity_id)).where("day <= ?", CurriculumDay.new(Time.current.yesterday, cohort).to_s).order(day: :desc)
    else
      Activity.none
    end
  end

  def completed_code_reviews
    assistance_requests.where(type: 'CodeReviewRequest').joins(:assistance).references(:assistance).where.not(assistances: { end_at: nil }).order(created_at: :desc).where(cohort_id: cohort_id)
  end

  # 1
  def code_reviewed_activities
    # intentionally including archived ones (for past students)
    Activity.where(id: completed_code_reviews.select(:activity_id))
  end

  # 2
  def submitted_but_not_reviewed_activities
    unreviewed_submissions = activity_submissions.where(cohort_id: cohort_id).proper.where.not(activity_id: completed_code_reviews.select(:activity_id))
    Activity.bootcamp.reverse_chronological_for_day.where(id: unreviewed_submissions.select(:activity_id))
  end

  # 3
  def unsubmitted_activities_before(day)
    Activity.active.countable_as_submission.where("day <= ?", day.to_s).reverse_chronological_for_day.where.not(id: activity_submissions.where(cohort_id: cohort_id).proper.select(:activity_id))
  end

  def visible_bootcamp_activities
    activities = Activity.bootcamp.active.order(day: :asc, sequence: :asc)
    if cohort
      day = CurriculumDay.new(Date.current, cohort).unlocked_until_day
      activities = activities.where("day <= ?", day.to_s)
    end
    activities
  end

  class << self

    def authenticate_via_github(auth)
      @user = where(uid: auth["uid"]).first
      return @user if @user
      @user = new
      @user.uid = auth["uid"]
      @user.save(validate: false)
      @user.update_columns(attributes_from_oauth(auth))
      @user
    end

    private

    def attributes_from_oauth(auth)
      {
        token:           auth["credentials"]["token"],
        github_username: auth["info"]["nickname"],
        first_name:      auth["info"]["name"].to_s.split.first,
        last_name:       auth["info"]["name"].to_s.split.last,
        avatar_url:      auth["info"]["image"],
        email:           auth["info"]["email"]
      }
    end

  end

end
