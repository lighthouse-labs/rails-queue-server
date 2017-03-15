class QuizActivity < Activity

  belongs_to :quiz

  validates :quiz, presence: true

  def display_vague_duration?
    true
  end

  def display_duration?
    false
  end

end
