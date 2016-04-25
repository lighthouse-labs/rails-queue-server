class EvaluationsController < ApplicationController
  before_action :find_project, only: [:new, :create]
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
    if @evaluation.save
      redirect_to day_path "today"
    else
      render :new
    end
  end

  def edit
  end

  def update
  end

  private

  def find_project
    @project = Project.find_by(slug: params[:project_id])
  end

  def evaluation_params
    params.require(:evaluation).permit(:url, :notes)
  end
end
