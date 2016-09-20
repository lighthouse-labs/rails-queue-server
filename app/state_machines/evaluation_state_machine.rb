class EvaluationStateMachine
  include Statesman::Machine

  attr_accessor :current_user

  state :pending, initial: true
  state :in_progress
  state :accepted
  state :rejected
  state :cancelled

  transition from: :pending, to: [:in_progress, :cancelled]
  transition from: :in_progress, to: [:pending, :accepted, :rejected, :cancelled]
  transition from: :accepted, to: [:rejected]
  transition from: :rejected, to: [:accepted]

  guard_transition(to: :in_progress) do |evaluation|
    evaluation.teacher.presence
  end

  after_transition(to: :in_progress) do |evaluation, transition|
    evaluation.state = "in_progress"
    evaluation.started_at = Time.now
    evaluation.save
  end

  after_transition(to: :accepted) do |evaluation, transition|
    evaluation.state = "accepted"
    evaluation.completed_at = Time.now
    evaluation.save
  end

  after_transition(to: :pending) do |evaluation, transition|
    evaluation.state = "pending"
    evaluation.started_at = nil
    evaluation.teacher = nil
    evaluation.save
  end

  after_transition(to: :rejected) do |evaluation, transition|
    evaluation.state = "rejected"
    evaluation.completed_at = Time.now
    evaluation.save
  end

  after_transition(to: :cancelled) do |evaluation, transition|
    evaluation.state = "cancelled"
    evaluation.cancelled_at = Time.now
    evaluation.save
  end
end
