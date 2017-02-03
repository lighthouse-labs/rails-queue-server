class ActivityFeedback < ApplicationRecord

  belongs_to :activity
  belongs_to :user

  validates :user, presence: true
  validates :activity, presence: true
  validate :at_least_some_feedback

  scope :reverse_chronological_order, -> { order("activity_feedbacks.updated_at DESC")}
  scope :filter_by_user, -> (user_id) { where("user_id = ?", user_id) }
  scope :filter_by_day, -> (day) {
    includes(:activity).
    where("activities.day LIKE ?", day.downcase+"%").
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
    Time.use_zone((location_id ? Location.find(location_id) : Location.first).timezone) do
      where("activity_feedbacks.created_at >= ?", Time.zone.parse(date_str).beginning_of_day.utc)
    end
  }
  scope :filter_by_end_date, -> (date_str, location_id) {
    Time.use_zone((location_id ? Location.find(location_id) : Location.first).timezone) do
      where("activity_feedbacks.created_at <= ?", Time.zone.parse(date_str).end_of_day.utc)
    end
  }
  scope :filter_by_type, -> (type) {
    if type == 'Bootcamp'
      includes(:activity).where.not(activities: { day: [nil, ''] }).references(:activity)
    elsif type == 'Prep'
      includes(:activity).where(activities: { day: [nil, ''] }).references(:activity)
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

 #example options: {user_id: 1, user_location_id: 12}
  def self.filter_by(options)
    location_id = options[:user_location_id]
    options.inject(all) do |result, (k, v)|
      attribute = k.gsub("_id", "") #change user_id to user
      if attribute.include?('date')
        result.send("filter_by_#{attribute}", v, location_id)
      else
        #example ActivityFeedback.all.filter_by_attribute(1).filter_by_user_location(12)
        result.send("filter_by_#{attribute}", v)
      end
    end
  end

  def self.filter_by_completed(value, result)
    if value == 'true'
      result.completed
    elsif value == 'expired'
      result.expired.pending
    else
      result.pending
    end
  end

  def self.average_rating
    average(:rating).to_f.round(2)
  end

  def self.to_csv
    CSV.generate do |csv|
      csv << ['Student First Name', 'Student Last Name', 'Activity Name', 'Activity Day', 'Rating', 'Created Date', 'Location']
      all.each do |activity_feedback|
        csv << (activity_feedback.user.attributes.values_at('first_name', 'last_name') +
                activity_feedback.activity.attributes.values_at("name", "day") +
                activity_feedback.attributes.values_at('rating','created_at') +
                activity_feedback.user.cohort.location.attributes.values_at('name'))
      end
    end
  end

  private

  def at_least_some_feedback
    errors.add(:base, "Need at least some feedback (rating and/or detail) please!") if self.rating.blank? && self.detail.blank?
  end

end
