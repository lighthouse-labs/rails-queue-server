class Activity < ActiveRecord::Base

  belongs_to :section

  # optional. Means content stored on server
  belongs_to :content_repository

  has_many :activity_submissions, -> { order(:user_id) }
  has_many :messages, -> { order(created_at: :desc) }, class_name: 'ActivityMessage'
  has_many :recordings, -> { order(created_at: :desc) }
  has_many :feedbacks, as: :feedbackable
  has_many :activity_feedbacks, dependent: :destroy # new, to replace the above

  has_many :item_outcomes, as: :item, dependent: :destroy
  has_many :outcomes, through: :item_outcomes

  has_one :activity_test
  accepts_nested_attributes_for :activity_test

  validates :name, presence: true, length: { maximum: 56 }
  validates :duration, numericality: { only_integer: true }
  validates :start_time, numericality: { only_integer: true }, if: Proc.new{|activity| activity.section.blank?}
  validates :day, format: { with: DAY_REGEX, allow_blank: true }

  scope :chronological, -> { order("start_time, id") }
  scope :for_day, -> (day) { where(day: day.to_s) }
  scope :search, -> (query) { where("lower(name) LIKE :query or lower(day) LIKE :query", query: "%#{query.downcase}%") }

  after_update :add_revision_to_gist

  # to avoid callback on .update via instruction download
  attr_accessor :fetching_remote_content

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

    return (hours + duration_hours) * 100 + (minutes + duration_minutes)
  end

  def next
    if prep?
      self.section.activities.where('activities.id > ?', self.id).first
    else
      Activity.where('start_time > ? AND day = ?', self.start_time, self.day).order(start_time: :asc).first
    end
  end

  def previous
    if prep?
      self.section.activities.where('activities.id < ?', self.id).last
    else
      Activity.where('start_time < ? AND day = ?', self.start_time, self.day).order(start_time: :desc).first
    end
  end

  def display_duration?
    type != 'Lecture' && type != 'Test'
  end

  def repo_full_name
    content_repository.try :full_name
  end

  def prep?
    self.section
  end

  # Also could be overwritten by sub classes
  def create_outcome_results?
    evaluates_code?
  end


  protected

  def add_revision_to_gist
    if self.changes.any?
      # For now don't bother with this, content already mostly in repo - KV
      # puts "DOING REVISION GIST!"
      # g = ActivityRevision.new(self)
      # g.commit
    end
  end

  def gist_id
    self.gist_url.split('/').last
  end

end
