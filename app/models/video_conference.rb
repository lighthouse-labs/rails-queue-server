class VideoConference < ApplicationRecord

  belongs_to :user
  belongs_to :activity
  belongs_to :cohort

  validates :start_time, :duration, :status, :zoom_meeting_id, :start_url, :join_url, presence: true
  validates :status, inclusion: { in: %w[waiting started broadcast finished] }

  validates :cohort, uniqueness: {
    scope:      [:activity_id],
    message:    "only one active conference per cohort activity",
    conditions: -> { where(status: %w[waiting started broadcast]) }
  }

  validates :user_id, uniqueness: {
    message:    "only one active conference per user",
    conditions: -> { where(status: %w[waiting started broadcast]) }
  }

  scope :for_cohort, ->(cohort) { where(cohort: cohort) }
  scope :for_activity, ->(activity) { where(activity: activity) }
  scope :active, -> { where(status: %w[waiting started broadcast]) }
  scope :broadcasting, -> { where(status: ['broadcast']) }

  def active?
    %w[waiting started broadcast].include? status
  end

  def broadcasting?
    status == 'broadcast'
  end

  def is_host?(potential_host)
    user.attributes == potential_host.attributes
  end

  def host
    user
  end

  def cohort?
    cohort.present?
  end

  def public_status
    case status
    when 'finished'
      'Finished'
    when 'waiting', 'started'
      'Pending'
    else
      'Broadcasting'
    end
  end

  def student_link
    link = Rails.application.routes.url_helpers.activity_path(activity) if activity
    link ||= join_url
  end

  def end_time
    Time.parse(start_time) + duration.minutes
  end

end
