class User < ApplicationRecord

  include PgSearch::Model
  pg_search_scope :by_keywords,
                  against: [:first_name, :last_name, :email, :phone_number, :github_username, :slack, :bio, :quirky_fact, :specialties],
                  using:   {
                    tsearch: {
                      dictionary: "english",
                      any_word:   true,
                      prefix:     true
                    }
                  }

  belongs_to :cohort
  belongs_to :initial_cohort, class_name: 'Cohort' # rollover student have this set
  belongs_to :location

  has_many :activity_submissions
  has_many :activity_feedbacks, dependent: :destroy
  has_many :submitted_activities, through: :activity_submissions, source: :activity
  has_many :outcome_results
  has_many :evaluations
  has_many :quiz_submissions

  has_many :tech_interviews, foreign_key: 'interviewee_id'
  has_many :performed_tech_interviews, foreign_key: 'interviewer_id', class_name: 'TechInterviewResult'

  has_many :video_conferences

  has_many :tag_attributions, as: :taggable
  has_many :tags, through: :tag_attributions

  # use methods instead of AR relations while users are stored in seperated db
  # has_many :queue_tasks
  # has_many :user_status_logs

  scope :order_by_last_assisted_at, -> {
    order("last_assisted_at ASC NULLS FIRST")
  }
  scope :order_by_first_name, -> {
    order(first_name: :asc)
  }
  scope :order_by_name, -> {
    order(first_name: :asc, last_name: :asc)
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

  # Temp logic, until we get better (role-based?) permission mgmt throughout the app - KV
  def can_adminify?(user)
    super_admin? && !user.super_admin?
  end

  def can_allow_view_programming_tests?
    super_admin?
  end

  def prospect?
    true
  end

  def initials
    "#{first_name.first.upcase}#{last_name.first.upcase}"
  end

  def enrolled_and_prepping?
    cohort&.upcoming?
  end

  def active_student?
    false
  end

  def alumni?
    false
  end

  def deactivate!
    update! deactivated_at: Time.current
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
    (unlocked_until_day? && day.to_s <= unlocked_until_day) || day.unlocked?(location.timezone)
  end

  def can_access_day?(day)
    return unlocked? CurriculumDay.new(day, cohort) if cohort

    false
  end

  def position_in_queue
    assistance_requests.where(type: nil).pending.newest_requests_first.first.try(:position_in_queue)
  end

  def current_assistance_conference
    assistances.in_progress.order_by_start.last&.conference_link
  end

  def waiting_for_assistance?
    assistance_requests.where(type: nil).pending.exists?
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

  def full_name_with_pronoun
    if pronoun?
      "#{full_name} (#{pronoun})"
    else
      full_name
    end
  end

  def complete_submissions
    # Code evaluated activities need to be finalized, other activies only need to have time spent
    activity_submissions.where(finalized: true).or(activity_submissions.where.not(time_spent: nil)).select(:activity_id)
  end

  def incomplete_activities
    if cohort.started? && !cohort.on_curriculum_day?('w01d1')
      Activity.active.countable_as_submission.past_due_for_cohort(cohort).where.not(id: complete_submissions).order(day: :desc)
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
      day = CurriculumDay.new(Date.current, cohort).unlocked_until_day(location.timezone)
      activities = activities.where("day <= ?", day.to_s)
    end
    activities
  end

  def use_double_digit_week?
    Program.first.weeks >= 10
  end

  def unique_id
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), "unique-lhl-id", "#{id}-#{created_at}")
  end

  def eligible_for_github_education_pack?
    ENV['GITHUB_EDUCATION_SCHOOL_ID'].present? &&
      ENV['GITHUB_EDUCATION_SECRET_KEY'].present? &&
      active_student?
  end

  def github_education_pack_claimed?
    github_education_action == 'claimed'
  end

  def github_education_pack_actioned?
    github_education_action.present?
  end

  def active_video_conference
    video_conferences&.active&.last || cohort&.video_conferences&.broadcasting&.last
  end

  def hosting_active_video_conference?
    video_conferences&.active.present?
  end

  def assigned_ar?(assistance_request)
    queue_tasks.where(assistance_request: assistance_request).exists?
  end

  def toggle_duty
    self.on_duty = !on_duty
    status_log = UserStatusLog.using(:master).new(
      user_uid: uid,
      status:   on_duty ? 'on_duty' : 'off_duty'
    )
    status_log.save
    save
  end

  def set_duty(value)
    self.on_duty = value
    status_log = UserStatusLog.using(:master).new(
      user_uid: uid,
      status:   value ? 'on_duty' : 'off_duty'
    )
    save
  end

  def all_tags
    tags | (cohort&.tags || [])
  end

  def tagged_with?(tag)
    all_tags.include?(tag)
  end

  def assistances
    Assistance.for_user(self)
  end

  def assistance_requests
    AssistanceRequest.requested_by(self)
  end

  def queue_tasks
    QueueTask.for_user(self)
  end

  def user_status_logs
    UserStatusLogs.for_user(self)
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
