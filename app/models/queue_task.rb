class QueueTask < ApplicationRecord

  belongs_to :user
  belongs_to :assistance_request

  scope :for_teacher, ->(teacher) { where(user: teacher) }
  scope :teachers_queue_or_in_progress, ->(teacher) {
    left_joins(assistance_request: :assistance)
      .where(assistance_requests: { canceled_at: nil })
      .where("( assistances.id IS NULL AND queue_tasks.user_id = ? ) OR assistances.end_at IS NULL", teacher.id)
  }
  scope :open_tasks, -> { joins(:assistance_request).merge(AssistanceRequest.open_requests) }
  scope :in_progress_tasks, -> { joins(:assistance_request).merge(AssistanceRequest.in_progress_requests) }
  scope :open_or_in_progress_tasks, -> { joins(:assistance_request).merge(AssistanceRequest.open_or_in_progress_requests) }

  delegate :open?, to: :assistance_request

  delegate :in_progress?, to: :assistance_request

  def state
    if assistance_request.open?
      'pending'
    elsif assistance_request.in_progress? && user === assistance_request.assistance&.assistor
      'in_progress'
    else
      'closed'
    end
  end

end
