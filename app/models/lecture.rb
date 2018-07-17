class Lecture < Activity

  def allow_feedback?
    false
  end

  def display_duration?
    false
  end

  def completable?
    false
  end

end
