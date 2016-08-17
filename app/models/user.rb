class User < ActiveRecord::Base

  mount_uploader :custom_avatar, CustomAvatarUploader

  belongs_to :cohort
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

  scope :order_by_last_assisted_at, -> {
    order("last_assisted_at ASC NULLS FIRST")
  }
  scope :cohort_in_locations, -> (locations) {
    if locations.is_a?(Array) && locations.length > 0
      includes(cohort: :location).
      where(locations: {name: locations}).
      references(:cohort, :location)
    end
  }
  scope :active, -> {
    where(deactivated_at: nil, completed_registration: true)
  }
  scope :completed_activity, -> (activity) {
    if activity.is_a?(QuizActivity)
      # For quiz activities, we don't have activity submissions, and quiz_submissions are used to determine completion instead
      joins(:quiz_submissions).where(quiz_submissions: { initial: true, quiz_id: activity.quiz_id })
    else
      joins(:activity_submissions).where(activity_submissions: { activity: activity })
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

  def prepping?
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

  def deactivated?
    self.deactivated_at?
  end

  def reactivate!
    update! deactivated_at: nil
  end

  def unlocked?(day)
    # for special students we can unlock future material using `unlocked_until_day` field
    (unlocked_until_day? && day.to_s <= unlocked_until_day) || day.unlocked?
  end

  def can_access_day?(day)
    unlocked? CurriculumDay.new(day, cohort)
  end

  def being_assisted?
    self.assistance_requests.where(type: nil).in_progress_requests.exists?
  end

  def position_in_queue
    self.assistance_requests.where(type: nil).open_requests.newest_requests_first.first.try(:position_in_queue)
  end

  def current_assistor
    self.assistance_requests.where(type: nil).in_progress_requests.newest_requests_first.first.try(:assistance).try(:assistor)
  end

  def waiting_for_assistance?
    self.assistance_requests.where(type: nil).open_requests.exists?
  end

  def completed_activity?(activity)
    if activity.evaluates_code?
      activity_submissions.where(finalized: true, activity: activity).any?
    elsif activity.is_a?(QuizActivity)
      activity.quiz.latest_submission_by(self).present?
    else
      submitted_activities.include?(activity)
    end
  end

  def github_url(activity)
    activity_submissions.where(activity: activity).first.try(:github_url) if completed_activity?(activity)
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def incomplete_activities
    Activity.where.not(id: self.activity_submissions.select(:activity_id)).where("day <= ?", CurriculumDay.new(Date.today, cohort).to_s).order(:day).reverse
  end

  def completed_code_reviews
    self.assistance_requests.where(type: 'CodeReviewRequest').joins(:assistance).references(:assistance).where.not(assistances: { end_at: nil }).order(created_at: :desc)
  end

  # 1
  def code_reviewed_activities
    Activity.where(id: completed_code_reviews.select(:activity_id))
  end

  # 2
  def submitted_but_not_reviewed_activities
    unreviewed_submissions = self.activity_submissions.with_github_url.where.not(activity_id: completed_code_reviews.select(:activity_id))
    Activity.where(id: unreviewed_submissions.select(:activity_id))
  end

  # 3
  def unsubmitted_activities_before(day)
    Activity.active.where(allow_submissions: true).where("day <= ?", day.to_s).order(day: :desc).where.not(id: self.activity_submissions.select(:activity_id))
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
        token: auth["credentials"]["token"],
        github_username: auth["info"]["nickname"],
        first_name: auth["info"]["name"].to_s.split.first,
        last_name: auth["info"]["name"].to_s.split.last,
        avatar_url: auth["info"]["image"],
        email: auth["info"]["email"]
      }
    end
  end

end
