class EvaluationStateMachine
  include Statesman::Machine

  attr_accessor :current_user

  state :pending, initial: true
  state :in_progress
  state :accepted
  state :rejected
  state :cancelled

  transition from: :pending, to: [:in_progress, :cancelled]
  transition from: :in_progress, to: [:accepted, :rejected, :cancelled]

  guard_transition(to: :in_progress) do |evaluation|
    evaluation.teacher.presence
  end

  after_transition(to: :in_progress) do |evaluation, transition|
    evaluation.state = "in_progress"
    evaluation.started_at = DateTime.now
    evaluation.save
  end

  after_transition(to: :accepted) do |evaluation, transition|
    evaluation.state = "accepted"
    evaluation.completed_at = DateTime.now
    evaluation.save
  end

  after_transition(to: :rejected) do |evaluation, transition|
    evaluation.state = "rejected"
    evaluation.completed_at = DateTime.now
    evaluation.save
  end

  after_transition(to: :cancelled) do |evaluation, transition|
    evaluation.state = "cancelled"
    evaluation.save
  end
end
