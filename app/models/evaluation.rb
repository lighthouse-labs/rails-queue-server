class Evaluation < ApplicationRecord

  include Statesman::Adapters::ActiveRecordQueries

  belongs_to :project
  belongs_to :student
  belongs_to :teacher
  belongs_to :cohort # multiple cohorts per student sometimes

  has_many :evaluation_transitions, autosave: false

  include PgSearch
  pg_search_scope :by_keywords,
                  associated_against: {
                    student: [:first_name, :last_name, :email, :github_username],
                    teacher: [:first_name, :last_name, :email, :github_username]
                  },
                  using:              {
                    tsearch: {
                      dictionary: "english",
                      any_word:   true,
                      prefix:     true
                    }
                  }

  validates :github_url, presence: true

  validates :github_url,
            format: { with: URI.regexp(%w[http https]), message: "must be a valid format" }

<<<<<<< HEAD
  scope :newest_completed_first, -> { order(completed_at: :desc) }
=======
  scope :newest_first, -> { order(created_at: :desc) }
>>>>>>> 10fc3cfcb0f537e2d95616da64137140a2f83c07
  scope :oldest_first, -> { order(created_at: :asc) }

  scope :open_evaluations, -> { includes(:project).includes(:student).where(state: "pending") }
  scope :in_progress_evaluations, -> { where(state: "in_progress").where.not(teacher_id: nil) }
  scope :completed, -> { where.not(completed_at: nil) }
  scope :incomplete, -> { where(completed_at: nil) }
  scope :exclude_cancelled, -> { where.not(state: 'cancelled') }

  scope :student_cohort_in_locations, ->(locations) {
    if locations.is_a?(Array) && !locations.empty?
      includes(student: { cohort: :location })
        .where(locations: { name: locations })
        .references(:student, :cohort, :location)
    end
  }

  scope :student_cohort_in_location, ->(location) {
    joins(:student, :cohort).where(cohorts: { location_id: location.id })
  }

  scope :student_location, ->(location) {
    includes(:student).references(:student).where(users: { location_id: location.id })
  }

  scope :newest_active_evaluations_first, -> { order(started_at: :desc) }

  scope :for_project, ->(project) { where(project_id: project.id) }
  scope :after_date, ->(date) { where("evaluations.updated_at > ?", date) }
  scope :before_date, ->(date) { where("evaluations.updated_at < ?", date) }
  scope :exclude_autocomplete, -> { where.not(state: 'auto_accepted') }

  scope :pending, -> { where(state: 'pending') }
  scope :cancelled, -> { where(state: 'cancelled') }
  scope :in_progress, -> { where(state: 'in_progress') }
  scope :accepted, -> { where(state: 'accepted') }
  scope :rejected, -> { where(state: 'rejected')  }
  scope :auto_accepted, -> { where(state: 'auto_accepted') }

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
           :in_state?, to: :state_machine

  before_create :set_cohort
  before_create :take_snapshot_of_eval_criteria

  def self.filter_by(params, cohort, project)
    if params["evals"] && params["evals"].include?("All Evals")
      filter_by_all_evals(cohort, project)
    else
      filter_by_most_recent(cohort, project)
    end
  end

  def self.filter_by_all_evals(cohort, project)
    Evaluation.select("evaluations.id").from("evaluations").joins("JOIN users ON users.id = evaluations.student_id").where(users: { type: 'Student' }).where(users: { cohort_id: cohort }).where(project_id: project.id)
  end

  def self.filter_by_most_recent(cohort, project)
    Evaluation.select("e1.id").from("evaluations e1").joins("JOIN users ON users.id = e1.student_id").joins("LEFT JOIN evaluations e2 ON (e1.student_id = e2.student_id AND e1.created_at < e2.created_at)").where("e2.created_at IS NULL").where("users.id = e1.student_id").where("users.type = 'Student'").where("users.cohort_id = #{cohort.id}").where("e1.project_id = #{project.id}")
  end

  def state_machine
    @state_machine ||= EvaluationStateMachine.new(self, transition_class: EvaluationTransition)
  end

  def self.transition_class
    EvaluationTransition
  end

  def status
    current_state.tr('_', " ").titleize
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

  def completed?
    completed_at?
  end

  # in minutes
  def duration
    (completed_at - started_at).to_i
  end

  # in minutes
  def time_in_queue
    ((started_at || Time.current) - created_at).to_i
  end

  def rollover_submission?
    cohort_id != student.cohort_id
  end

  def sorted_rubric
    evaluation_rubric.sort_by { |_, data| data['order'] }.to_h
  end

  private_class_method :transition_class

  def self.initial_state
    :pending
  end

  private_class_method :initial_state

  # in minutes
  def duration
    (completed_at - started_at).to_i
  end

  # in minutes
  def time_in_queue
    ((started_at || Time.current) - created_at).to_i
  end

  def take_snapshot_of_eval_criteria
    self.evaluation_rubric    ||= project.evaluation_rubric
    self.evaluation_checklist ||= project.evaluation_checklist
    self.evaluation_guide     ||= project.evaluation_guide
    self.last_sha1            ||= project.last_sha1
  end

  # Using the new rubric+guide+checklist approach
  def v2?
    evaluation_rubric?
  end

  private

  def set_cohort
    self.cohort = student.cohort
  end

end
