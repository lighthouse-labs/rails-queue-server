class Assistance < ApplicationRecord

  include PgSearch

  belongs_to :assistor, class_name: User
  belongs_to :assistee, class_name: User
  belongs_to :activity
  belongs_to :cohort # substitute for lack of enrollment record - KV

  pg_search_scope :by_student_keywords,
                  associated_against: {
                    assistee: [:first_name, :last_name, :email]
                  },
                  using:              {
                    tsearch: {
                      dictionary: "english",
                      any_word:   true,
                      prefix:     true
                    }
                  }

  has_one :feedback, as: :feedbackable, dependent: :destroy
  has_one :assistance_request, dependent: :nullify

  validates :rating, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 4, allow_nil: true }

  before_create :set_cohort
  before_create :set_day
  before_create :set_start_at
  before_create :set_activity
  after_save :update_student_average
  before_create :set_secs_in_queue

  scope :currently_active, -> {
    joins(:assistance_request)
      .where("assistance_requests.canceled_at IS NULL AND assistances.end_at IS NULL")
  }
  # Why not just a simpler joins syntax?
  # See https://github.com/lighthouse-labs/compass/issues/672
  # If we use pg_search_scope's by_keywords scope then the join table has a diff unexpected name and the expected "users" relation simply doesn't work (SQL Error results)
  # If we DON'T use pg_searh_scope (ie no keywords) then AR works as expected and the join table is called "users"
  # Therefore we are being VERY explicit on relation name/alias when joinig with users, since it's also joined by pg_search which then causes errors.
  scope :with_user_location_id, ->(location_id) {
    joins('INNER JOIN users AS "assistees" ON assistees.id = assistances.assistee_id')
      .where(assistees: { location_id: location_id })
  }
  scope :completed, -> { where('assistances.end_at IS NOT NULL') }
  scope :has_assistance_request, -> { joins(:assistance_request) }
  scope :order_by_start, -> { order(:start_at) }
  scope :assisted_by, ->(user) { where(assistor: user) }
  scope :assisting, ->(user) { where(assistee: user) }
  scope :for_cohort, ->(cohort) { where(cohort_id: cohort) if cohort }

  scope :average_length, -> { average('EXTRACT(EPOCH FROM (assistances.end_at - assistances.start_at)) / 60.0').to_f }

  RATING_BASELINE = 3

  def end(notes, notify, rating = nil, student_notes = nil)
    self.notes = notes
    self.rating = rating
    self.student_notes = student_notes
    self.end_at = Time.current
    self.flag = notify
    save!
    assistee.last_assisted_at = Time.current

    if assistance_request.instance_of?(CodeReviewRequest) && !rating.nil? && !assistee.code_review_percent.nil?
      assistee.code_review_percent += Assistance::RATING_BASELINE - rating
      UserMailer.new_code_review_message(self).deliver_later
    end

    UserMailer.notify_education_manager(self).deliver_later if flag?

    assistee.save.tap do
      create_feedback(student: assistee, teacher: assistor)
      UserChannel.broadcast_to assistee, type:   "NewFeedback",
                                         object: assistee.feedbacks.pending.where.not(feedbackable: nil).not_expired.count
      send_notes_to_slack
    end
  end

  def to_json
    {
      start_time: start_at,
      id:         id,
      assistee:   {
        avatar_url: assistee.avatar_url,
        full_name:  assistee.full_name
      }
    }
  end

  private

  def set_cohort
    self.cohort_id = assistee.try :cohort_id
  end

  def set_day
    self.day = CurriculumDay.new(Time.current, cohort).to_s if cohort
  end

  def set_activity
    self.activity ||= assistance_request.activity if assistance_request
  end

  def set_start_at
    self.start_at ||= Time.current
  end

  def send_notes_to_slack
    post_to_slack(ENV['SLACK_CHANNEL'])
    post_to_slack(ENV['SLACK_CHANNEL_REMOTE']) if assistee.remote
  end

  def update_student_average
    if assistee
      assistee.cohort_assistance_average = assistee.assistances.completed.where(cohort_id: assistee.cohort_id).where.not(rating: nil).average(:rating).to_f.round(2)
      assistee.save!
    end
  end

  def set_secs_in_queue
    ar = assistance_request
    if ar && start_at
      self.secs_in_queue = start_at - ar.created_at
      ar.save!
    end
  end

  def post_to_slack(channel)
    return if ENV['SLACK_TOKEN'].nil? || channel.nil?
    options = {
      username: assistor.github_username,
      icon_url: assistor.avatar_url,
      channel:  channel
    }
    begin
      poster = Slack::Poster.new('lighthouse', ENV['SLACK_TOKEN'], options)
      poster.send_message("*Assisted #{assistee.full_name} for #{((end_at - start_at) / 60).to_i} minutes*:\n #{notes}")
    rescue StandardError
    end
  end

end
