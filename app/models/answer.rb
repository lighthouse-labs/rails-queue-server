class Answer < ApplicationRecord

  belongs_to :option

  belongs_to :quiz_submission

  scope :correct, -> { joins(:option).where(options: { correct: true }) }
end
