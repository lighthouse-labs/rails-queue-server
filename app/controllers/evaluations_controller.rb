class EvaluationsController < ApplicationController
  before_action :find_project, only: [:new, :create]
  before_action :find_evaluation, only: [:show, :edit, :update]
  def index
  end

  def show
  end

  def new
    @evaluation = Evaluation.new
  end

  def create
    @evaluation = Evaluation.new(evaluation_params)
    @evaluation.project = @project
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
    binding.pry
  end

  private

  def find_project
    @project = Project.find_by(slug: params[:project_id])
  end

  def find_evaluation
    @evaluation = Evaluation.find params[:id]
  end

  def evaluation_params
    params.require(:evaluation).permit(:url, :notes)
  end
end
