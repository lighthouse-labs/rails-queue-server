class Evaluation < ActiveRecord::Base

  belongs_to :project
  belongs_to :student
  belongs_to :teacher

  validates_presence_of :notes, :url

  def status
    if teacher && accepted
      "accepted"
    elsif teacher && !accepted
      "rejected"
    elsif teacher
      "in progress"
    else
      "pending"
    end
  end
end
