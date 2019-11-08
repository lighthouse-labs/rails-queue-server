class ProgrammingTest::Attempt < ApplicationRecord

  include Statesman::Adapters::ActiveRecordQueries

  has_many :programming_test_attempt_transitions, class_name: 'ProgrammingTest::Attempt::Transition', autosave: false, dependent: :destroy, inverse_of: :attempt

  belongs_to :student
  belongs_to :cohort
  belongs_to :programming_test

  delegate :current_state, :transition_to, to: :state_machine

  ## VALIDATIONS ##

  validates :student, presence: true
  validates :cohort, presence: true
  validates :programming_test, presence: true

  ## HELPERS ##



  ## STATE MACHINE ##

  def state_machine
    @state_machine ||= ProgrammingTest::Attempt::StateMachine.new(self, transition_class: ProgrammingTest::Attempt::Transition)
  end

  def self.transition_name
    :programming_test_attempt_transitions
  end

  def self.transition_class
    ProgrammingTest::Attempt::Transition
  end
  private_class_method :transition_class

  def self.initial_state
    :pending
  end
  private_class_method :initial_state

end
