class ProgrammingTestAttemptStateMachine

  include Statesman::Machine

  state :pending, initial: true
  state :ready
  state :errored

  transition from: :pending, to: [:errored, :ready]
  transition from: :errored, to: :pending

end
