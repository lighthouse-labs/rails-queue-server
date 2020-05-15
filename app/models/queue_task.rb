class QueueTask < ApplicationRecord

  allow_shard :master

  # belongs_to :assistor, class_name: User, foreign_key: "assistor_uid", primary_key: 'uid'
  belongs_to :assistance_request

  before_create :set_start_at

  scope :pending, -> { joins(:assistance_request).merge(AssistanceRequest.pending) }
  scope :in_progress, -> { joins(:assistance_request).merge(AssistanceRequest.in_progress) }
  scope :pending_or_in_progress, -> { joins(:assistance_request).merge(AssistanceRequest.pending_or_in_progress) }
  
  scope :for_user, ->(user) { where(assistor_uid: user.uid) }
  scope :teachers_queue_or_in_progress, ->(uid) {
    left_joins(assistance_request: :assistance)
      .where(assistance_requests: { canceled_at: nil })
      .where("( assistances.id IS NULL AND queue_tasks.assistor_uid = ? ) OR assistances.end_at IS NULL", uid)
  }
  scope :for_resource, ->(resource) { joins(:assistance_request).where("assistance_requests.request->>'resource_type' = ?", resource) }
  scope :this_month, -> { joins(:assistance_request).where(assistance_requests: { created_at: DateTime.now.beginning_of_month..DateTime.now.end_of_month }) }

  delegate :pending?, to: :assistance_request

  delegate :in_progress?, to: :assistance_request

  def state
    if assistance_request.pending?
      'pending'
    elsif assistance_request.in_progress? && assistor === assistance_request.assistance&.assistor
      'in_progress'
    else
      'closed'
    end
  end

  def position_in_queue
    assistor.queue_tasks.pending.where('queue_tasks.id < ?', id).count + 1 if open?
  end

  def set_start_at
    self.start_at = Time.current
  end

  def assistor
    User.using(:web).find_by(uid: assistor_uid)
  end

end
