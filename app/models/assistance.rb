class Assistance < ApplicationRecord

  belongs_to :assistor, class_name: User
  belongs_to :assistee, class_name: User
  belongs_to :activity
  belongs_to :cohort # substitute for lack of enrollment record - KV

  has_one :feedback, as: :feedbackable, dependent: :destroy
  has_one :assistance_request, dependent: :nullify

  validates :rating, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 4, allow_nil: true }

  before_create :set_cohort
  before_create :set_day
  before_create :set_start_at
  before_create :set_activity

  scope :currently_active, -> {
    joins(:assistance_request)
      .where("assistance_requests.canceled_at IS NULL AND assistances.end_at IS NULL")
  }
  scope :completed, -> { where('assistances.end_at IS NOT NULL') }
  scope :order_by_start, -> { order(:start_at) }
  scope :assisted_by, ->(user) { where(assistor: user) }
  scope :assisting, ->(user) { where(assistee: user) }

  RATING_BASELINE = 3

  def end(notes, rating = nil, student_notes = nil)
    self.notes = notes
    self.rating = rating
    self.student_notes = student_notes
    self.end_at = Time.now
    save
    assistee.last_assisted_at = Time.now
    if assistance_request.instance_of?(CodeReviewRequest) && !rating.nil? && !assistee.code_review_percent.nil?
      assistee.code_review_percent += Assistance::RATING_BASELINE - rating
      UserMailer.new_code_review_message(self).deliver
    end

    assistee.save.tap do
      create_feedback(student: assistee, teacher: assistor)
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
    self.start_at = Time.now
  end

  def send_notes_to_slack
    post_to_slack(ENV['SLACK_CHANNEL'])
    post_to_slack(ENV['SLACK_CHANNEL_REMOTE']) if assistee.remote
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
    rescue
    end
  end

end
