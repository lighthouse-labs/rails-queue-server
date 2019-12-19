class ProgrammingTestAttempt < ApplicationRecord

  include Statesman::Adapters::ActiveRecordQueries

  has_many :programming_test_attempt_transitions, foreign_key: :attempt_id, autosave: false, dependent: :destroy, inverse_of: :attempt

  belongs_to :student
  belongs_to :cohort
  belongs_to :programming_test

  delegate :current_state, :transition_to, :in_state?, to: :state_machine

  ## VALIDATIONS ##

  validates :student, presence: true
  validates :cohort, presence: true
  validates :programming_test, presence: true

  ## HELPERS ##

  def ready?
    current_state == 'ready'
  end

  def errored?
    current_state == 'errored'
  end

  def pending?
    current_state == 'pending'
  end

  def token
    ready? ? programming_test_attempt_transitions.last.metadata["token"] : nil
  end

  def token=(token)
    transition_to(:ready, token: token)
  end

  def errored=(error)
    transition_to(:errored, error)
  end

  def reset
    transition_to(:pending)
  end

  def as_json(params)
    json = super.as_json(params)

    json[:token] = token

    json
  end

  def status
    case current_state
    when 'ready'
      'Started'
    when 'errored'
      'Error'
    when 'pending'
      'Pending'
    end
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
