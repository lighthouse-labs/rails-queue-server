class ActivityFeedback < ApplicationRecord

  belongs_to :feedbackable
  belongs_to :activity
  belongs_to :user

  validates :user, presence: true
  validates :activity, presence: true
  validate :at_least_some_feedback

  # scope :activity_feedbacks, -> { where(sentiment: nil) }
  # scope :expired, -> { where("activity_feedbacks.created_at < ?", Date.today-1) }
  # scope :not_expired, -> {where("activity_feedbacks.created_at >= ?", Date.today-1)}
  # # scope :completed, -> { where(rating: nil) }
  # scope :pending, -> { where(rating: nil) }
  scope :reverse_chronological_order, -> { order("activity_feedbacks.updated_at DESC")}
  scope :filter_by_user, -> (user_id) { where("user_id = ?", user_id) }
  scope :filter_by_day, -> (day) {
    includes(:activity).
    where("day LIKE ?", day.downcase+"%").
    references(:activity)
  }
  scope :filter_by_program, -> (program_id) {
    includes(user: {cohort: :program}).
    where(programs: {id: program_id}).
    references(:user, :cohort, :program)
  }
  scope :filter_by_user_location, -> (location_id) {
    includes(user: :location).
    where(locations: {id: location_id}).
    references(:user, :location)
  }
  scope :filter_by_cohort, -> (cohort_id) {
    includes(user: :cohort).
    where(cohorts: {id: cohort_id}).
    references(:user, :cohort)
  }
  scope :filter_by_start_date, -> (date_str, location_id) {
    Time.use_zone(Location.find(location_id).timezone) do
      where("activity_feedbacks.created_at >= ?", Time.zone.parse(date_str).beginning_of_day.utc)
    end
  }
  scope :filter_by_end_date, -> (date_str, location_id) {
    Time.use_zone(Location.find(location_id).timezone) do
      where("activity_feedbacks.created_at <= ?", Time.zone.parse(date_str).end_of_day.utc)
    end
  }

  default_scope -> { order(created_at: :desc) }

  def positive?
    sentiment == 1
  end

  def negative?
    sentiment == -1
  end

  def ok?
    sentiment == 0
  end

  def self.average_rating
    average(:rating).to_f.round(2)
  end

  def self.filter_by(options)
    location_id = options[:user_location_id]
    options.inject(all) do |result, (k, v)|
      attribute = k.gsub("_id", "")
      if attribute.include?('date')
        result.send("filter_by_#{attribute}", v, location_id)
      else
        result.send("filter_by_#{attribute}", v)
      end
    end
  end

  private

  def at_least_some_feedback
    errors.add(:base, "Need at least some feedback (rating and/or detail) please!") if self.rating.blank? && self.detail.blank?
  end

end
