class PinnedNote < Activity

  def allow_feedback?
    false
  end

  def can_mark_completed?
    false
  end

  def completable?
    false
  end

end
