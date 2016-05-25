class Evaluation < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordQueries

  belongs_to :project
  belongs_to :student
  belongs_to :teacher

  has_many :evaluation_transitions, autosave: false

  validates_presence_of :github_url

  validates :github_url,
    format: { with: URI::regexp(%w(http https)), message: "must be a valid format" }

  scope :open_evaluations, -> { includes(:project).includes(:student).where(state: "pending") }

  scope :in_progress_evaluations, -> { where(state: "in_progress").where.not(teacher_id: nil) }

  scope :student_cohort_in_locations, -> (locations) {
    if locations.is_a?(Array) && locations.length > 0
      includes(student: {cohort: :location}).
      where(locations: {name: locations}).
      references(:student, :cohort, :location)
    end
  }

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
