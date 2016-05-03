class EvaluationsController < ApplicationController
  
  before_action :find_project, only: [:new, :create]
  before_action :find_evaluation, only: [:show, :edit, :update]
  
  def index
    @evaluations = @project.evaluations
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
      redirect_to day_path "today"
    else
      render :new
    end
  end

  def edit
    @evaluation_form = EvaluationForm.new @evaluation
  end

  def update
    result = MarkEvaluation.call(evaluation_form: params, evaluation: @evaluation)
    if result.success?
      redirect_to [@project, @evaluation], notice: "Evaluation successfully marked."
    else
      redirect_to action: :edit, notice: result.message
    end
  end

  private

  def find_project
    @project = Project.find_by(slug: params[:project_id])
  end

  def find_evaluation
    @evaluation = @project.evaluations.find params[:id]
  end

  def evaluation_params
    params.require(:evaluation).permit(:url, :notes)
  end
end
