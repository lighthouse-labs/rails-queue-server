class EvaluationsController < ApplicationController

  before_action :teacher_required, except: [:new, :create, :cancel, :show]
  before_action :find_project
  before_action :find_evaluation, only: [:show, :edit, :update, :start_marking, :cancel, :cancel_marking]
  before_action :check_can_evaluate, only: [:edit, :update]

  def index
    @evaluations = if session[:cohort_id]
                     @project.evaluations.joins(:student).where('users.cohort_id = ?', session[:cohort_id]).order('users.first_name')
                   else
                     @project.evaluations
                   end
  end

  def show
    load_all_completed_evals
    render 'show_new' if @evaluation.v2?
  end

  def new
    @evaluation = @project.evaluations.new
  end

  def create
    @evaluation = @project.evaluations.new(evaluation_params)
    @evaluation.student = current_user

    if @evaluation.save
      if @project.evaluated?
        BroadcastEvaluationToTeachers.call(evaluation: @evaluation)
      else
        @evaluation.transition_to!(:auto_accepted)
      end
      redirect_to [@project, @evaluation], notice: "Project successfully submitted for evaluation."
    else
      flash.now[:alert] = @evaluation.errors.full_messages
      render :new
    end
  end

  def edit
    load_all_completed_evals

    # TODO: remove this check once all the old evals clear - KV
    if @evaluation.v2?
      render 'edit_new' # otherwise just `edit`
    else
      @evaluation_form = EvaluationForm.new @evaluation
    end
  end

  def update
    if request.xhr?
      save_changes
    else
      finish_marking
    end
  end

  def start_marking
    @evaluation.teacher = current_user
    @evaluation.transition_to!(:in_progress)
    BroadcastMarking.call(evaluation: @evaluation)
    redirect_to edit_project_evaluation_path(@project, @evaluation)
  end

  # aka re-queue
  def cancel_marking
    @evaluation.teacher = nil
    @evaluation.transition_to!(:pending)
    BroadcastMarking.call(evaluation: @evaluation)
    redirect_to project_evaluation_path(@project, @evaluation), notice: 'Evaluation is again up for grabs by mentors'
  end

  def cancel
    unless @evaluation.transition_to :cancelled
      flash[:alert] = "Could not cancel evaluation. Maybe it has already been evaluated?"
    end
    redirect_to @project
  end

  private

  def check_can_evaluate
    if !@evaluation.markable?
      redirect_to [@project, @evaluation], alert: 'Evaluation is not markable'
    elsif @evaluation.teacher != current_user
      redirect_to [@project, @evaluation], alert: 'You are not the evaluator'
    end
  end

  def save_changes
    result = Evaluations::UpdateResult.call(
      evaluation_form: params[:evaluation],
      evaluation:      @evaluation
    )
    render json: { success: true }
  end

  def finish_marking
    if @evaluation.v2?
      finish_marking_v2
    else
      finish_marking_v1
    end
  end

  # TODO: remove me (and any other v2 logic/code) after a few weeks - KV May 11 2017
  def finish_marking_v1
    result = CompleteEvaluation.call(
      evaluation_form: params[:evaluation_form],
      evaluation:      @evaluation,
      decision:        params[:commit]
    )
    if result.success?
      redirect_to [@project, @evaluation], notice: "Evaluation successfully marked."
    else
      redirect_to action: :edit, notice: result.message
    end
  end

  def finish_marking_v2
    result = Evaluations::Complete.call(
      evaluation_form: params[:evaluation],
      evaluation:      @evaluation
    )
    if result.success?
      redirect_to [@project, @evaluation], notice: "Evaluation marked. Student notified. You were cc'd."
    else
      load_all_completed_evals
      render :edit_new
    end
  end

  def find_project
    @project = Project.find_by(slug: params[:project_id])
  end

  def find_evaluation
    @evaluation = @project.evaluations.find(params[:id] ? params[:id] : params[:evaluation_id])

    # security: students can only access their own evals
    if student?
      redirect_to :root, alert: 'Not Allowed' unless @evaluation.student == current_user
    end
  end

  def evaluation_params
    params.require(:evaluation).permit(:github_url, :student_notes, :resubmission)
  end

  def teacher_required
    redirect_to day_path('today'), alert: 'Not allowed' unless teacher?
  end

  def load_all_completed_evals
    @all_completed_evaluations = @project.evaluations_for(@evaluation.student).completed.where.not(id: @evaluation.id)
  end

end
