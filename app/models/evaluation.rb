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

  scope :oldest_first, -> { order(created_at: :asc) }

  scope :open_evaluations, -> { includes(:project).includes(:student).where(state: "pending") }

  scope :in_progress_evaluations, -> { where(state: "in_progress").where.not(teacher_id: nil) }

  scope :completed, -> { where.not(completed_at: nil) }

  scope :student_cohort_in_locations, -> (locations) {
    if locations.is_a?(Array) && locations.length > 0
      includes(student: {cohort: :location}).
      where(locations: {name: locations}).
      references(:student, :cohort, :location)
    end
  }
  scope :student_location, -> (location) {
    includes(:student).references(:student).where(users: { location_id: location.id })
  }

  scope :newest_active_evaluations_first, -> { order(started_at: :desc) }

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
           :in_state?, to: :state_machine

  before_create :set_cohort

  # def self.filter_by(options)
  #     location_id = options[:teacher_location_id] || options[:student_location_id]
  #     options.inject(all) do |result, (k, v)|
  #       attribute = k.gsub("_id", "")
  #       if attribute == 'completed?'
  #         self.filter_by_completed(v, result)
  #       elsif attribute.include?('date')
  #         result.send("filter_by_#{attribute}", v, location_id)
  #       else
  #         result.send("filter_by_#{attribute}", v)
  #       end
  #     end
  #   end

  def self.filter_by(params, cohort)
    if params["evals"]
      if params["evals"].include?("All Evals")
        filter_by_all_evals(cohort)
      else
        filter_by_most_recent
      end
    else
      filter_by_most_recent
    end
    # if true
    #   Evaluation.where(student_id: student.id).order(created_at: :desc).take(1)
    #   #add cohort id
    # else
    #   Evaluation.where(student_id: student.id)
    # end
  end

  def self.filter_by_all_evals(cohort)
    #cohort.students.joins("JOIN evaluations ON evaluations.student_id = users.id").order(created_at: :desc)
    #Evaluation.where(cohort_id: 5).order(created_at: :desc)
    Evaluation.find_by_sql("SELECT * FROM evaluations JOIN users ON users.id = evaluations.student_id WHERE users.type = 'Student' AND users.cohort_id = 5")
    #Evaluation.find_by_sql("SELECT evaluations.id from evaluations JOIN users ON users.id = evaluations.student_id WHERE users.type = 'Student' AND users.cohort_id = 5")
  end

  def self.filter_by_most_recent
    Evaluation.find_by_sql("SELECT e1.* FROM evaluations e1 JOIN users ON users.id = e1.student_id LEFT JOIN evaluations e2 ON (e1.student_id = e2.student_id AND e1.created_at < e2.created_at) WHERE e2.created_at IS NULL AND users.id = e1.student_id AND users.type = 'Student' AND users.cohort_id = 5")
  end

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

   # in minutes
  def duration
    (completed_at - started_at).to_i
  end

  # in minutes
  def time_in_queue
    ((started_at || Time.current) - created_at).to_i
  end

  private_class_method :transition_class

  def self.initial_state
    :pending
  end

  private_class_method :initial_state

  private

  def set_cohort
    self.cohort = self.student.cohort
  end

end
