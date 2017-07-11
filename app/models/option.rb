class Option < ApplicationRecord

  belongs_to :question

  has_many :answers, dependent: :nullify

  default_scope -> { order(id: :asc) }

  def selected?(submission)
    submission.option_selected?(self)
  end

end
