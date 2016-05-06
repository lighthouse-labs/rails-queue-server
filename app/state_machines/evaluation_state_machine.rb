class EvaluationStateMachine
  include Statesman::Machine

  attr_accessor :current_user

  state :pending, initial: true
  state :in_progress
  state :accepted
  state :rejected

  transition from: :pending, to: :in_progress
  transition from: :in_progress, to: [:accepted, :rejected]

  guard_transition(to: :in_progress) do |evaluation|
    evaluation.teacher.presence
  end

  after_transition(to: :in_progress) do |evaluation, transition|
    evaluation.state = "in_progress"
    evaluation.save
  end

  after_transition(to: :accepted) do |evaluation, transition|
    evaluation.state = "accepted"
    evaluation.save
  end

  after_transition(to: :rejected) do |evaluation, transition|
    evaluation.state = "rejected"
    evaluation.save
  end
end
