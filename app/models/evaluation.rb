class Evaluation < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordQueries

  belongs_to :project
  belongs_to :student
  belongs_to :teacher

  has_many :evaluation_transitions, autosave: false

  validates_presence_of :notes, :url

  validates :github_url,
    presence: :true,
    format: { with: URI::regexp(%w(http https)), message: "must be a valid format" }

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
           :in_state?, to: :state_machine

  def state_machine
    @state_machine ||= EvaluationStateMachine.new(self, transition_class: EvaluationTransition)
  end

  def self.transition_class
    EvaluationTransition
  end

  def status
    state.gsub(/_/, " ").titleize
  end

  private_class_method :transition_class

  def self.initial_state
    :pending
  end

  private_class_method :initial_state

end
