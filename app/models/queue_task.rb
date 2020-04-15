class QueueTask < ApplicationRecord

  belongs_to :user
  belongs_to :assitance_request

  scope :for_teacher, ->(teacher) { where(user: teacher) }

  def active?
    assitance_request.open?
  end
  
end
