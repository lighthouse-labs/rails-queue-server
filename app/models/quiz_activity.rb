class QuizActivity < Activity

  belongs_to :quiz

  validates :quiz, presence: true

  def display_vague_duration?
    true
  end

  def display_duration?
    false
  end

  # can complete/submit, but not using typical mark completed flow
  def can_mark_completed?
    false
  end

end
