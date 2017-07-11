class Question < ApplicationRecord

  belongs_to :outcome

  # enable autosave b/c of how the curriculum deploy (load_quiz) scripts work - KV
  has_many :options, dependent: :destroy, autosave: true
  has_many :answers, through: :options

  has_many :outcome_results, as: :source

  has_and_belongs_to_many :quizzes

  accepts_nested_attributes_for :options, allow_destroy: true

  validates :question, presence: true

  scope :active, -> { where(active: true) }

  scope :stats, ->(quiz) {
    question_stats = select('questions.*', 'options.correct AS options_correct', 'COUNT(answers.id) AS answers_count')
                     .group('questions.id', 'options.correct')
                     .joins('LEFT JOIN options ON questions.id = options.question_id')
                     .joins('LEFT JOIN answers ON answers.option_id = options.id')
    if quiz
      question_stats = question_stats
                       .where('answers.id IN (SELECT answers.id FROM answers JOIN quiz_submissions ON quiz_submissions.id = answers.quiz_submission_id WHERE quiz_submissions.quiz_id = ?)', quiz.id)
    end
    question_stats
  }

  scope :initial_stats, ->(quiz) {
    question_stats = select('questions.*', 'options.correct AS options_correct', 'COUNT(answers.id) AS answers_count')
                     .group('questions.id', 'options.correct')
                     .joins('LEFT JOIN options ON questions.id = options.question_id')
                     .joins('LEFT JOIN answers ON answers.option_id = options.id')
    if quiz
      question_stats = question_stats
                       .where('answers.id IN (SELECT answers.id FROM answers JOIN quiz_submissions ON quiz_submissions.id = answers.quiz_submission_id WHERE quiz_submissions.quiz_id = ? AND quiz_submissions.initial = true)', quiz.id)
    end
    question_stats
  }

end
