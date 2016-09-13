class Evaluation < ApplicationRecord

  include Statesman::Adapters::ActiveRecordQueries

  belongs_to :project
  belongs_to :student
  belongs_to :teacher
  belongs_to :cohort # multiple cohorts per student sometimes

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

  scope :newest_evaluations_first, -> { order(created_at: :desc) }
  scope :newest_active_evaluations_first, -> { order(started_at: :desc) }

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
           :in_state?, to: :state_machine

  def state_machine
    @state_machine ||= EvaluationStateMachine.new(self, transition_class: EvaluationTransition)
  end

  def self.transition_class
    EvaluationTransition
  end

  def status
    current_state.gsub(/_/, " ").titleize
  end

  def cancellable?
    !in_state?(:accepted, :rejected, :cancelled)
  end

  def markable?
    in_state?(:pending, :in_progress)
  end

  def markable_by?(user)
    in_state?(:in_progress) && teacher == user
  end

  def grabbable_by?(user)
    in_state?(:pending) || (in_state?(:in_progress) && user != teacher)
  end

  def can_requeue?
    markable?
  end

  private_class_method :transition_class

  def self.initial_state
    :pending
  end

  private_class_method :initial_state

end
