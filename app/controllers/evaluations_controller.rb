class EvaluationsController < ApplicationController

  before_action :teacher_required, except: [:new, :create, :cancel_evaluation]
  before_action :find_project
  before_action :find_evaluation, only: [:show, :edit, :update, :start_marking, :cancel_evaluation]

  def index
    if session[:cohort_id]
      @evaluations = @project.evaluations.joins(:student).where('users.cohort_id = ?', session[:cohort_id])
    else
      @evaluations = @project.evaluations
    end
  end

  def show
  end

  def new
    @evaluation = @project.evaluations.new
  end

  def create
    @evaluation = @project.evaluations.new(evaluation_params)
    @evaluation.student = current_user
    if @evaluation.save
      redirect_to projects_path, notice: "Project successfully submitted."
    else
      flash[:alert] = @evaluation.errors.full_messages
      render :new
    end
  end

  def edit
    @evaluation_form = EvaluationForm.new @evaluation
  end

  def update
    result = CompleteEvaluation.call(evaluation_form: params[:evaluation_form], evaluation: @evaluation)
    if result.success?
      redirect_to [@project, @evaluation], notice: "Evaluation successfully marked."
    else
      redirect_to action: :edit, notice: result.message
    end
  end

  def start_marking
    @evaluation.teacher = current_user
    @evaluation.transition_to(:in_progress)
    redirect_to edit_project_evaluation_path(@project, @evaluation)
  end

  def cancel_evaluation
    binding.pry
    @evaluation.transition_to :cancelled
    redirect_to @project
  end

  private

  def find_project
    @project = Project.find_by(slug: params[:project_id])
  end

  def find_evaluation
    @evaluation = @project.evaluations.find(params[:id] ? params[:id] : params[:evaluation_id])
  end

  def evaluation_params
    params.require(:evaluation).permit(:github_url, :student_notes)
  end

  def teacher_required
    redirect_to day_path('today'), alert: 'Not allowed' unless teacher?
  end
end
