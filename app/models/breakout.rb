class Breakout < Activity

  has_many :lectures, -> { order(created_at: :desc) }, foreign_key: :activity_id

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

  def can_mark_completed?
    false
  end

  def completable?
    false
  end

end
