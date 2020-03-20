class VideoConference < ApplicationRecord

  belongs_to :user
  belongs_to :activity
  belongs_to :cohort

  validates_presence_of :start_time, :duration, :status, :zoom_meeting_id, :start_url, :join_url
  validates :status, :inclusion=> { :in => ['waiting', 'started', 'broadcast', 'finished'] }

  scope :core,    -> { where(stretch: [nil, false]) }
  scope :stretch, -> { where(stretch: true) }
  scope :milestone, -> { where(milestone: true) }

  def active?
    status == 'active'
  end

  # Given the start_time and duration, return the end_time
  def end_time
    Time.parse(start_time) + duration.minutes
  end

end
