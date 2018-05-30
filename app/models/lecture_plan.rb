class LecturePlan < Activity

  has_many :lectures, ->{ order(created_at: :desc) }, foreign_key: :activity_id

  # This means we can call .lectures (assoc) on this instance
  def has_lectures?
    true
  end

  def allow_feedback?
    false
  end

  def display_duration?
    false
  end

end
