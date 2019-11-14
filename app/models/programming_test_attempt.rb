class ProgrammingTestAttempt < ApplicationRecord

  include Statesman::Adapters::ActiveRecordQueries

  has_many :programming_test_attempt_transitions, foreign_key: :attempt_id, autosave: false, dependent: :destroy, inverse_of: :attempt

  belongs_to :student
  belongs_to :cohort
  belongs_to :programming_test

  delegate :current_state, :transition_to, to: :state_machine

  ## VALIDATIONS ##

  validates :student, presence: true
  validates :cohort, presence: true
  validates :programming_test, presence: true

  ## HELPERS ##

  def token
    current_state == 'ready' ? programming_test_attempt_transitions.last.metadata["token"] : nil
  end

  def as_json(params)
    json = super.as_json(params)

    json[:token] = token

    json
  end

  ## STATE MACHINE ##

  def state_machine
    @state_machine ||= ProgrammingTestAttemptStateMachine.new(self, transition_class: ProgrammingTestAttemptTransition)
  end

  def self.transition_class
    ProgrammingTestAttemptTransition
  end
  private_class_method :transition_class

  def self.initial_state
    :pending
  end
  private_class_method :initial_state

end
