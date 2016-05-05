class Evaluation < ActiveRecord::Base

  belongs_to :project
  belongs_to :student
  belongs_to :teacher


  validates_presence_of :notes, :url

  def state_machine
    @state_machine ||= EvaluationStateMachine.new(self)#, transition_class: EvaluationTransition)
  end

  # def self.transition_class
  #   EvaluationTransition
  # end

  def self.initial_state
    :pending
  end

  def pending?
    status == "pending"
  end

  private_class_method :initial_state

end
